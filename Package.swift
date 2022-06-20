// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "aws-asg-tags-lambda",
  dependencies: [
    .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "0.5.2")
  ],
  targets: [
    .executableTarget(
      name: "Run",
      dependencies: [
        .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime")
      ]),
    .testTarget(
      name: "LambdaTests",
      dependencies: ["Run"])
  ]
)
