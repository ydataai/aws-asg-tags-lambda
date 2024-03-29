import Foundation

extension ClusterNodesTags: Codable {
  public enum CodingKeys: String, CodingKey {
    case clusterName = "ClusterName"
    case commonTags = "CommonTags"
    case nodePools = "NodePools"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.init(
      clusterName: try container.decode(String.self, forKey: .clusterName),
      commonTags: try container.decodeIfPresent([Tag].self, forKey: .commonTags),
      nodePools: try container.decode([NodePool].self, forKey: .nodePools)
    )
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(clusterName, forKey: .clusterName)
    try container.encodeIfPresent(commonTags, forKey: .commonTags)
    try container.encode(nodePools, forKey: .nodePools)
  }
}
