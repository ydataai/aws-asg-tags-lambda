// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "aws-asg-tags-lambda",
  platforms: [
    .macOS(.v12)
  ],
  dependencies: [
    .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha.2"),
    .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", from: "0.4.0"),
    .package(url: "https://github.com/soto-project/soto.git", from: "7.0.0"),
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.2"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
  ],
  targets: [
    .target(name: "Models"),
    .target(
      name: "App",
      dependencies: [
        .byName(name: "Models"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
        .product(name: "SotoAutoScaling", package: "soto"),
        .product(name: "SotoEKS", package: "soto")
      ],
      swiftSettings: [ .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)) ]
    ),
    .executableTarget(
      name: "CloudFormation",
      dependencies: [
        .byName(name: "App"),
        .byName(name: "Models"),
        .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events")
      ],
      swiftSettings: [ .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)) ]
    ),
    .executableTarget(
      name: "Command",
      dependencies: [
        .byName(name: "App"),
        .byName(name: "Models"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      swiftSettings: [ .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)) ]
    )
  ]
)
