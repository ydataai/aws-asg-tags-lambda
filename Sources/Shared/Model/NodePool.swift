import Foundation

public struct NodePool {
  public let name: String
  public let tags: [Tag]
}

extension NodePool: Codable {
  enum CodingKeys: String, CodingKey {
    case name = "Name"
    case tags = "Tags"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.name = try container.decode(String.self, forKey: .name)
    self.tags = try container.decode([Tag].self, forKey: .tags)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(name, forKey: .name)
    try container.encode(tags, forKey: .tags)
  }
}
