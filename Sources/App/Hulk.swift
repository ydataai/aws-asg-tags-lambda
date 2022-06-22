import Foundation
import Models
import SotoAutoScaling
import SotoEKS

struct Hulk {
  let asgClient: any ASGClientRepresentable
  let eksClient: any EKSClientRepresentable

  init(asgClient: any ASGClientRepresentable, eksClient: any EKSClientRepresentable) {
    self.asgClient = asgClient
    self.eksClient = eksClient
  }

  func smash(_ properties: RequestProperties) async throws {
    let asgNames = try await withThrowingTaskGroup(
      of: (String, EKS.Nodegroup).self,
      returning: [(String, [String])].self
    ) { taskGroup in
      properties.nodePools.forEach { nodePool in
        taskGroup.addTask {
          (
            nodePool.name,
            try await eksClient.describeNodeGroup(name: nodePool.name, clusterName: properties.clusterName)
          )
        }
      }

      return try await taskGroup.reduce([(String, [String])]()) { finalResult, node in
        let groups = node.1.resources?.autoScalingGroups?.compactMap { $0.name }

        return groups.flatMap { finalResult + [(node.0, $0)] } ?? finalResult
      }
    }

    let tags = asgNames.reduce([AutoScaling.Tag]()) { finalResult, asg in
      guard let nodePool = properties.nodePools[asg.0] else { return finalResult }

      let allTags = properties.commonTags + nodePool.tags

      return finalResult + allTags.flatMap { tag in
        asg.1.map { AutoScaling.Tag(key: tag.name, resourceId: $0, value: tag.value) }
      }
    }

    try await asgClient.updateTags(tags)
  }
}
