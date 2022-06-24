import BetterCodable
import Foundation

public struct Tag {
  public let name: String
  public let value: String
  @LosslessBoolValue public var propagateAtLaunch: Bool

  public init(name: String, value: String, propagateAtLaunch: Bool) {
    self.name = name
    self.value = value
    self.propagateAtLaunch = propagateAtLaunch
  }
}
