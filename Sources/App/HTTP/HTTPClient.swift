import AsyncHTTPClient
import Foundation
import Logging
import struct NIO.ByteBuffer

public protocol HTTPClientRepresentable {
  func terminateCloudFormationInvocation<E: Encodable>(_ url: String, event: E) async throws
}

public enum HTTP {
  public struct Client: HTTPClientRepresentable {
    let provider: any HTTPClientProvider
    let logger: Logger
    let encoder: JSONEncoder

    public init(provider: any HTTPClientProvider, logger: Logger, encoder: JSONEncoder = JSONEncoder()) {
      self.provider = provider
      self.logger = logger
      self.encoder = encoder
    }

    public func terminateCloudFormationInvocation<E: Encodable>(_ url: String, event: E) async throws {
      var request = HTTPClientRequest(url: url)

      request.headers.add(name: "Content-Type", value: "")

      var byteBuffer = ByteBuffer()
      try encoder.encode(event, into: &byteBuffer)
      request.body = .bytes(byteBuffer)

      let response = try await provider.execute(request, timeout: .seconds(30), logger: logger)
      if response.status != .ok {
        throw Error.failedWithResponse(response)
      }
    }
  }
}

extension HTTP.Client {
  enum Error: Swift.Error {
    case failedWithResponse(HTTPClientResponse)
  }
}


