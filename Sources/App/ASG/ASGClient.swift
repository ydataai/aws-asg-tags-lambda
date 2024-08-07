import Foundation
import SotoAutoScaling

public protocol ASGClientRepresentable {
  func updateTags(_ tags: [AutoScaling.Tag]) async throws
}

public struct ASGClient: ASGClientRepresentable {
  let logger: Logger
  let provider: AutoScaling

  public init(logger: Logger, provider: AutoScaling) {
    self.logger = logger
    self.provider = provider
  }

  public func updateTags(_ tags: [AutoScaling.Tag]) async throws {
    let updatedTags = tags.map {
      AutoScaling.Tag(
        key: $0.key,
        propagateAtLaunch: $0.propagateAtLaunch,
        resourceId: $0.resourceId,
        resourceType: $0.resourceType ?? "auto-scaling-group",
        value: $0.value)
    }

    let request = AutoScaling.CreateOrUpdateTagsType(tags: updatedTags)

    try await provider.createOrUpdateTags(request, logger: logger)
  }
}
