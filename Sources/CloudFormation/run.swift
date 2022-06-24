import App
import AsyncHTTPClient
import AWSLambdaEvents
import AWSLambdaRuntime
import Models
import NIO

@main
struct CloudFormationHandler: LambdaHandler {
  typealias Event = CloudFormation.Request<ClusterNodesTags, ClusterNodesTags>
  typealias Output = Void

  let app: Application
  let httpClient: HTTP.Client

  init(context: LambdaInitializationContext) async throws {
    self.app = Application(context: context)

    let asyncHTTPClient = HTTPClient(eventLoopGroupProvider: .shared(context.eventLoop))
    context.terminator.register(name: "HTTPClient", handler: asyncHTTPClient.shutdown)

    self.httpClient = HTTP.Client(provider: asyncHTTPClient, logger: context.logger)
  }

  func handle(_ event: Event, context: LambdaContext) async throws -> Output {
    context.logger.info("running lambda with event \n\(event)")

    guard let resourceProperties = event.resourceProperties else {
      return try await terminate(with: event, result: .failure(Error.missingResourceProperties))
    }

    context.logger.info("extracted resource properties\n\(resourceProperties)")

    let result = await app.run(with: resourceProperties, runContext: context)

    context.logger.info("got result\n\(result)")

    try await terminate(with: event, result: result)
  }

  private func terminate<E: Swift.Error>(with event: Event, result: LambdaResult<E>) async throws {
    try await httpClient.terminateCloudFormationInvocation(event.responseURL, event: result.encode(for: event))
  }
}

extension LambdaResult {
  func encode<D: Codable>(for request: CloudFormation.Request<D, D>) -> CloudFormation.Response<D> {
    switch self {
    case .success:
      return CloudFormation.Response<D>(
        status: .success,
        requestId: request.requestId,
        logicalResourceId: request.logicalResourceId,
        stackId: request.stackId,
        physicalResourceId: request.physicalResourceId,
        reason: nil,
        noEcho: nil,
        data: nil
      )
    case .failure(let error):
      return CloudFormation.Response<D>(
        status: .failed,
        requestId: request.requestId,
        logicalResourceId: request.logicalResourceId,
        stackId: request.stackId,
        physicalResourceId: request.physicalResourceId,
        reason: error.localizedDescription,
        noEcho: nil,
        data: nil
      )
    }
  }
}

extension CloudFormationHandler {
  enum Error: Swift.Error {
    case missingResourceProperties
  }
}

extension HTTPClient {
  func shutdown(eventLoop: EventLoop) -> EventLoopFuture<Void> {
    let promise = eventLoop.makePromise(of: Void.self)

    promise.completeWithTask { try await self.shutdown() }

    return promise.futureResult
  }
}
