import AsyncHTTPClient
import Foundation
import struct Logging.Logger
import struct NIO.TimeAmount

public protocol HTTPClientProvider {
  func execute(_ request: HTTPClientRequest, timeout: TimeAmount, logger: Logger?) async throws -> HTTPClientResponse
}

extension HTTPClient: HTTPClientProvider {}
