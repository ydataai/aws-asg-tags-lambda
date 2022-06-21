// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "aws-asg-tags-lambda",
  platforms: [
    .macOS(.v12)
  ],
  dependencies: [
    .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", branch: "main"),
    .package(url: "https://github.com/ydataai/swift-aws-lambda-events.git", branch: "main")
  ],
  targets: [
    .target(
      name: "Shared",
      dependencies: [
        .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
        .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events")
      ]
    ),
    .executableTarget(name: "CloudFormation", dependencies: [.byName(name: "Shared")])
  ]
)
