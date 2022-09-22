import Foundation

extension Tag: Codable {
  enum CodingKeys: String, CodingKey {
    case name = "Name"
    case value = "Value"
    case propagateAtLaunch = "PropagateAtLaunch"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)



    self.init(
      name: try container.decode(String.self, forKey: .name),
      value: try container.decode(String.self, forKey: .value),
      propagateAtLaunch: try container.decodeBool(forKey: .propagateAtLaunch)
    )
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(name, forKey: .name)
    try container.encode(value, forKey: .value)
    try container.encode(propagateAtLaunch, forKey: .propagateAtLaunch)
  }
}

extension KeyedDecodingContainer {
  func decodeBool(forKey key: Key) throws -> Bool {
    do {
      return try decode(Bool.self, forKey: key)
    } catch {
      guard
        let stringValue = try? decode(String.self, forKey: key),
        let boolValue = Bool(stringValue)
      else {
        throw error
      }

      return boolValue
    }
  }
}
