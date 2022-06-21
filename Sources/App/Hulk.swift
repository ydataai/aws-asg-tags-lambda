import Foundation
import Models
import SotoAutoScaling
import SotoEKS

struct Hulk<ASG: ASGClientRepresentable, EKS: EKSClientRepresentable> {
  let asgClient: ASG
  let eksClient: EKS

  init(asgClient: ASG, eksClient: EKS) {
    self.asgClient = asgClient
    self.eksClient = eksClient
  }

  func smash(_ properties: RequestProperties) async throws {
  }
}
