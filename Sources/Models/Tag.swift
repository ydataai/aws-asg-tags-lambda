import Foundation

public struct Tag {
  public let name: String
  public let value: String
  public let propagateAtLaunch: Bool

  public init(name: String, value: String, propagateAtLaunch: Bool) {
    self.name = name
    self.value = value
    self.propagateAtLaunch = propagateAtLaunch
  }
}
