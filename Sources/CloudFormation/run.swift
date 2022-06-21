import AWSLambdaEvents
import AWSLambdaRuntime
import Shared

@main
struct CloudFormationHandler: LambdaHandler {
  typealias Event = CloudFormation.Request<Shared.RequestProperties, Shared.RequestProperties>
  typealias Output = Void

  init(context: LambdaInitializationContext) async throws {}

  func handle(_ event: Event, context: LambdaContext) async throws -> Output {
    return ()
  }
}
