import AWSLambdaRuntime
import Models

public struct Application {
  let context: LambdaInitializationContext

  public init(context: LambdaInitializationContext) {
    self.context = context
  }

  public func run(properties: RequestProperties, runContext: LambdaContext) async -> LambdaResult<Error> {
    return .success(())
  }
}

extension Application {
  public enum Error: Swift.Error {
  }
}
