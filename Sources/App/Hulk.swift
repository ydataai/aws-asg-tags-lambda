import Foundation
import Models
import SotoAutoScaling
import SotoEKS

struct Hulk {
  let asgClient: any ASGClientRepresentable
  let eksClient: any EKSClientRepresentable
  let logger: Logger

  func smash(_ clusterInfo: ClusterNodesTags) async throws {
    logger.info("let's smash tags into ASGs with \(clusterInfo)")

    let asgNames = try await withThrowingTaskGroup(
      of: (String, EKS.Nodegroup).self,
      returning: [(String, [String])].self
    ) { taskGroup in
      clusterInfo.nodePools.forEach { nodePool in
        taskGroup.addTask {
          (
            nodePool.name,
            try await eksClient.describeNodeGroup(name: nodePool.name, clusterName: clusterInfo.clusterName)
          )
        }

        logger.debug("[TASKGROUP]: added task to fetch node info for \(nodePool.name)")
      }

      logger.info("added \(clusterInfo.nodePools.count) tasks fetch nodes for \(clusterInfo.clusterName)")

      return try await taskGroup.reduce([(String, [String])]()) { finalResult, node in
        logger.trace("extracting auto scaling groups for \(node.0) from \(node.1)")

        let groups = node.1.resources?.autoScalingGroups?.compactMap { $0.name }

        logger.debug("auto scaling groups for node \(node.0) 👉 \(String(describing: groups))")

        return groups.flatMap { finalResult + [(node.0, $0)] } ?? finalResult
      }
    }

    logger.info("fetched auto scaling groups from the cluster \(clusterInfo.clusterName): \n\(asgNames)")

    let tags = asgNames.reduce([AutoScaling.Tag]()) { finalResult, asg in
      guard let nodePool = clusterInfo.nodePools[asg.0] else { return finalResult }

      let allTags = (clusterInfo.commonTags ?? []) + (nodePool.tags ?? [])

      logger.debug("tags to add to node \(nodePool.name): \(allTags)")

      return finalResult + allTags.flatMap { tag in
        asg.1.map {
          AutoScaling.Tag(key: tag.name, propagateAtLaunch: tag.propagateAtLaunch, resourceId: $0, value: tag.value)
        }
      }
    }

    logger.info("will smash tags \(tags)")

    try await asgClient.updateTags(tags)

    logger.info("smashed tags with \(clusterInfo)")
  }
}
