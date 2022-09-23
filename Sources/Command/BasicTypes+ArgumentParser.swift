import ArgumentParser
import Foundation
import Models

extension Array: ExpressibleByArgument where Element: Decodable {
  public init?(argument: String) {
    guard let data = argument.data(using: .utf8) else {
      return nil
    }

    guard let decoded = try? JSONDecoder().decode(Self.self, from: data) else {
      return nil
    }

    self = decoded
  }
}

extension Optional: ExpressibleByArgument where Wrapped: ExpressibleByArgument {
  public init?(argument: String) {
    self = Wrapped(argument: argument)
  }
}
