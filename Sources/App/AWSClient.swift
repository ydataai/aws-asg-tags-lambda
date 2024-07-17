import Foundation
import NIO
import SotoCore

extension AWSClient {
  public func shutdown(eventLoop: EventLoop) -> EventLoopFuture<Void> {
    let promise = eventLoop.makePromise(of: Void.self)

    promise.completeWithTask {
      try await self.shutdown()
    }

    return promise.futureResult
  }
}
