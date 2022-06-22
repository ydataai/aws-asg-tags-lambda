import AWSLambdaRuntime
import Models
import SotoCore
import SotoAutoScaling
import SotoEKS

public struct Application {
  let context: LambdaInitializationContext

  let awsClient: AWSClient
  let hulk: Hulk

  public init(context: LambdaInitializationContext) {
    self.context = context

    self.awsClient = AWSClient(httpClientProvider: .createNewWithEventLoopGroup(self.context.eventLoop))
    self.context.terminator.register(name: "\(type(of: AWSClient.self))", handler: self.awsClient.shutdown)

    let eks = EKS(client: self.awsClient)
    let eksClient = EKSClient(logger: self.context.logger, provider: eks)

    let asg = AutoScaling(client: self.awsClient)
    let asgClient = ASGClient(logger: self.context.logger, provider: asg)

    self.hulk = Hulk(asgClient: asgClient, eksClient: eksClient)
  }

  public func run(properties: RequestProperties, runContext: LambdaContext) async -> LambdaResult<Error> {
    do {
      try await hulk.smash(properties)

      return .success(())
    } catch {
      return .failure(error)
    }
  }
}

extension AWSClient {
  func shutdown(eventLoop: EventLoop) -> EventLoopFuture<Void> {
    let promise = eventLoop.makePromise(of: Void.self)

    promise.completeWithTask { try await self.shutdown() }

    return promise.futureResult
  }
}
