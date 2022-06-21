import Foundation
import Models

extension Tag: Codable {
  enum CodingKeys: String, CodingKey {
    case name = "Name"
    case value = "Value"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.init(
      name: try container.decode(String.self, forKey: .name),
      value: try container.decode(String.self, forKey: .value)
    )
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(name, forKey: .name)
    try container.encode(value, forKey: .value)
  }
}
