import Foundation
import SotoAutoScaling

public protocol ASGProvider {
  func createOrUpdateTags(_ input: AutoScaling.CreateOrUpdateTagsType, logger: Logger) async throws
}

extension AutoScaling: ASGProvider {
  @inlinable
  public func createOrUpdateTags(_ input: CreateOrUpdateTagsType, logger: Logger) async throws {
    try await createOrUpdateTags(input, logger: logger, on: nil)
  }
}
