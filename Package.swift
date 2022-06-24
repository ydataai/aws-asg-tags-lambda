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
    .package(url: "https://github.com/ydataai/swift-aws-lambda-events.git", branch: "main"),
    .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0"),
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.11.1"),
    .package(url: "https://github.com/marksands/BetterCodable.git", from: "0.4.0")
  ],
  targets: [
    .target(
      name: "Models",
      dependencies: [ .product(name: "BetterCodable", package: "BetterCodable") ]
    ),
    .target(
      name: "App",
      dependencies: [
        .byName(name: "Models"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
        .product(name: "BetterCodable", package: "BetterCodable"),
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
    )
  ]
)
