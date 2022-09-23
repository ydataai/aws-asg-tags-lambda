import ArgumentParser
import Foundation

enum Environment {
  static var decoder = JSONDecoder()

  @inlinable
  static func get(_ key: String) throws -> String {
    guard let value = ProcessInfo.processInfo.environment[key] else {
      throw Error.keyNotFound
    }

    return value
  }

  static func get<Key: CodingKey>(_ key: Key) throws -> String {
    try get(key.stringValue)
  }

  @inlinable
  static func get<D: Decodable>(
    _ key: String,
    _ type: D.Type = D.self,
    decoder: JSONDecoder? = nil
  ) throws -> D {
    guard let data = try get(key).data(using: .utf8) else {
      throw Error.cannotConvertToData
    }

    let decoder = decoder ?? Self.decoder

    return try decoder.decode(D.self, from: data)
  }

  static func get<Key: CodingKey, D: Decodable>(
    _ key: Key,
    _ type: D.Type = D.self,
    decoder: JSONDecoder? = nil
  ) throws -> D {
    try get(key.stringValue)
  }
}

extension Environment {
  enum Error: Swift.Error {
    case keyNotFound
    case cannotConvertToData
  }
}
