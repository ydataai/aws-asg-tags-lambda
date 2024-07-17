import App
import ArgumentParser
import AsyncHTTPClient
import Foundation
import Models
import NIO
import SotoCore
import SotoAutoScaling
import SotoEKS

@main
struct Command: AsyncParsableCommand {
  static var configuration: CommandConfiguration { CommandConfiguration(commandName: "aws-asg-tags") }

  // swiftlint:disable force_try

  @Option(name: .shortAndLong)
  var clusterName: String = try! Environment.get(ClusterNodesTags.CodingKeys.clusterName)

  @Option(name: .long)
  var nodePools: [NodePool] = try! Environment.get(ClusterNodesTags.CodingKeys.nodePools)

  @Option(name: .long)
  var commonTags: [Tag]? = try? Environment.get(ClusterNodesTags.CodingKeys.commonTags)

  func run() async throws {
    let logger = Logger(label: "ai.ydata.aws-asg-tags")
    let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

    let awsClient = AWSClient(
      httpClient: HTTPClient(eventLoopGroup: eventLoop), logger: logger
    )

    defer {
      try! awsClient.syncShutdown() // swiftlint:disable:this force_try
    }

    let eks = EKS(client: awsClient)
    let eksClient = EKSClient(logger: logger, provider: eks)

    let asg = AutoScaling(client: awsClient)
    let asgClient = ASGClient(logger: logger, provider: asg)

    let hulk = Hulk(asgClient: asgClient, eksClient: eksClient, logger: logger)

    let clusterNodeTags = ClusterNodesTags(
      clusterName: clusterName,
      commonTags: commonTags,
      nodePools: nodePools
    )

    logger.info("processing cluster node tags:\n\(clusterNodeTags)")

    try await hulk.smash(clusterNodeTags)
  }
}

extension Command {
  enum Error: Swift.Error {
    case missingProperty
  }
}
