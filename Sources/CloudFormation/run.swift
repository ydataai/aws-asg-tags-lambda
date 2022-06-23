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
    guard let resourceProperties = event.resourceProperties else {
      throw Error.missingResourceProperties
    }

    let response = await app.run(with: resourceProperties, runContext: context).encode(for: event)

    try await httpClient.terminateCloudFormationInvocation(event.responseURL, event: response)
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
