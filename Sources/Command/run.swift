import App
import ArgumentParser
import Models
import NIO
import SotoCore
import SotoAutoScaling
import SotoEKS

@main
struct Command: AsyncParsableCommand {
  static var configuration: CommandConfiguration { CommandConfiguration(commandName: "aws-asg-tags") }


  func run() async throws {
    let logger = Logger(label: "ai.ydata.aws-asg-tags")
    let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

    let awsClient = AWSClient(
      httpClientProvider: .createNewWithEventLoopGroup(eventLoop),
      logger: logger
    )

    defer {
      try! awsClient.syncShutdown() // swiftlint:disable:this force_try
    }

    let eks = EKS(client: awsClient)
    let eksClient = EKSClient(logger: logger, provider: eks)

    let asg = AutoScaling(client: awsClient)
    let asgClient = ASGClient(logger: logger, provider: asg)

    let hulk = Hulk(asgClient: asgClient, eksClient: eksClient, logger: logger)

    let clusterNodeTags = try createClusterNodeTags(logger)

    try await hulk.smash(clusterNodeTags)
  }

  private func createClusterNodeTags(_ logger: Logger) throws -> ClusterNodesTags {
    guard let clusterName = Environment.get(ClusterNodesTags.CodingKeys.clusterName) else {
      logger.error("missing value for property \(ClusterNodesTags.CodingKeys.clusterName.description))")
      throw Error.missingProperty
    }

    logger.info("extracted clusterName from env: \(clusterName)")

    guard let nodePools: [NodePool] = try Environment.get(ClusterNodesTags.CodingKeys.nodePools) else {
      logger.error("missing value for property \(ClusterNodesTags.CodingKeys.nodePools.description))")
      throw Error.missingProperty
    }

    logger.info("extracted nodePools from env: \(nodePools)")

    let commonTags: [Tag]? = try Environment.get(ClusterNodesTags.CodingKeys.commonTags)

    logger.info("commonTags extracted from env: \(commonTags ?? [])")

    return ClusterNodesTags(clusterName: clusterName, commonTags: commonTags, nodePools: nodePools)
  }
}

extension Command {
  enum Error: Swift.Error {
    case missingProperty
  }
}
