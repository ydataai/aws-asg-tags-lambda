import Foundation
import SotoEKS

public protocol EKSProvider {
  func describeNodegroup(_ input: EKS.DescribeNodegroupRequest, logger: Logger) async throws
  -> EKS.DescribeNodegroupResponse
}

extension EKS: EKSProvider {
  @inlinable
  public func describeNodegroup(_ input: DescribeNodegroupRequest, logger: Logger) async throws
  -> DescribeNodegroupResponse {
    try await describeNodegroup(input, logger: logger, on: nil)
  }
}
