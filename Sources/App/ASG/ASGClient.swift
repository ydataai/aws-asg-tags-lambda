import Foundation
import SotoAutoScaling

protocol ASGClientRepresentable {
  func updateTags(_ tags: [AutoScaling.Tag]) async throws
}

struct ASGClient<Provider: ASGProvider>: ASGClientRepresentable {
  let logger: Logger
  let provider: Provider

  init(logger: Logger, provider: Provider) {
    self.logger = logger
    self.provider = provider
  }

  func updateTags(_ tags: [AutoScaling.Tag]) async throws {
    let updatedTags = tags.map {
      AutoScaling.Tag(
        key: $0.key,
        propagateAtLaunch: $0.propagateAtLaunch ?? true,
        resourceId: $0.resourceId,
        resourceType: $0.resourceType ?? "auto-scaling-group",
        value: $0.value)
    }

    let request = AutoScaling.CreateOrUpdateTagsType(tags: updatedTags)

    try await provider.createOrUpdateTags(request, logger: logger)
  }
}
