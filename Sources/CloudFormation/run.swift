import App
import AWSLambdaEvents
import AWSLambdaRuntime
import Models

@main
struct CloudFormationHandler: LambdaHandler {
  typealias Event = CloudFormation.Request<ClusterNodesTags, ClusterNodesTags>
  typealias Output = CloudFormation.Response<ClusterNodesTags>

  let app: Application

  init(context: LambdaInitializationContext) async throws {
    self.app = Application(context: context)
  }

  func handle(_ event: Event, context: LambdaContext) async throws -> Output {
    guard let resourceProperties = event.resourceProperties else {
      throw Error.missingResourceProperties
    }

    return await app.run(with: resourceProperties, runContext: context).encode(for: event)
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
