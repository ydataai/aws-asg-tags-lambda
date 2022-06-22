import Foundation

public struct RequestProperties {
  public let clusterName: String
  public let commonTags: [Tag]
  public let nodePools: [NodePool]

  public init(clusterName: String, commonTags: [Tag], nodePools: [NodePool]) {
    self.clusterName = clusterName
    self.commonTags = commonTags
    self.nodePools = nodePools
  }
}

public extension Array where Element == NodePool {
  subscript(nodePool: String) -> NodePool? {
    first { $0.name == nodePool }
  }
}
