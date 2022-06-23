import Foundation

public struct NodePool {
  public let name: String
  public let tags: [Tag]?

  public init(name: String, tags: [Tag]) {
    self.name = name
    self.tags = tags
  }
}
