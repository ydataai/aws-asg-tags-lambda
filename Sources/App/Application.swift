import AWSLambdaRuntime
import Models
import SotoCore
import SotoEKS

public struct Application {
  let context: LambdaInitializationContext

  let awsClient: AWSClient

  public init(context: LambdaInitializationContext) {
    self.context = context

    self.awsClient = AWSClient(httpClientProvider: .createNewWithEventLoopGroup(self.context.eventLoop))

    self.context.terminator.register(name: "\(type(of: AWSClient.self))", handler: self.awsClient.shutdown)
  }

  public func run(properties: RequestProperties, runContext: LambdaContext) async -> LambdaResult<Error> {
    return .success(())
  }
}

extension Application {
  public enum Error: Swift.Error {
  }
}

extension AWSClient {
  func shutdown(eventLoop: EventLoop) -> EventLoopFuture<Void> {
    let promise = eventLoop.makePromise(of: Void.self)

    promise.completeWithTask { try await self.shutdown() }

    return promise.futureResult
  }
}
