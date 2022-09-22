import Foundation

enum Environment {
  static var decoder: JSONDecoder = JSONDecoder()

  static func get<Key: CodingKey>(_ key: Key) -> String? {
    ProcessInfo.processInfo.environment[key.stringValue]
  }

  static func get<Key: CodingKey, D: Decodable>(
    _ key: Key,
    _ type: D.Type = D.self,
    decoder: JSONDecoder = Self.decoder
  ) throws -> D? {
    guard let data = get(key)?.data(using: .utf8) else {
      return nil
    }

    return try decoder.decode(D.self, from: data)
  }
}
