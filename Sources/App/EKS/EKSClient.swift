import SotoEKS

public protocol EKSClientRepresentable {
  func describeNodeGroup(name: String, clusterName: String) async throws -> EKS.Nodegroup
}

public struct EKSClient: EKSClientRepresentable {
  let logger: Logger
  let provider: EKS

  public init(logger: Logger, provider: EKS) {
    self.logger = logger
    self.provider = provider
  }

  public func describeNodeGroup(name: String, clusterName: String) async throws -> EKS.Nodegroup {
    let request = EKS.DescribeNodegroupRequest(clusterName: clusterName, nodegroupName: name)

    let response = try await provider.describeNodegroup(request, logger: logger)

    guard let nodeGroup = response.nodegroup else {
      throw Error.cannotFindNodeGroup(name, clusterName)
    }

    return nodeGroup
  }
}

public extension EKSClient {
  enum Error: Swift.Error {
    case cannotFindNodeGroup(_ name: String, _ clusterName: String)
  }
}
