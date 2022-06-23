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

    self.awsClient = AWSClient(
      httpClientProvider: .createNewWithEventLoopGroup(self.context.eventLoop),
      logger: self.context.logger
    )
    self.context.terminator.register(name: "\(type(of: AWSClient.self))", handler: self.awsClient.shutdown)

    let eks = EKS(client: self.awsClient)
    let eksClient = EKSClient(logger: self.context.logger, provider: eks)

    let asg = AutoScaling(client: self.awsClient)
    let asgClient = ASGClient(logger: self.context.logger, provider: asg)

    self.hulk = Hulk(asgClient: asgClient, eksClient: eksClient, logger: self.context.logger)
  }

  public func run(with clusterInfo: ClusterNodesTags, runContext: LambdaContext) async -> LambdaResult<Error> {
    runContext.logger.info("running lambda with event info \(clusterInfo)")

    do {
      try await hulk.smash(clusterInfo)

      runContext.logger.info("successfully run lambda with info \(clusterInfo)")

      return .success(())
    } catch {
      runContext.logger.error("failed to run lambda with \(clusterInfo) with error: \(error)")

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
