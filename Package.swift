// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "things",
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.0")),
    .package(url: "https://github.com/Miiha/SchemeClient", .upToNextMinor(from: "0.0.1"))
  ],
  targets: [
    .target(
      name: "things",
      dependencies: ["ThingsLibrary"]
    ),
    .target(
      name: "ThingsLibrary",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "SchemeClient", package: "SchemeClient")
      ]
    ),
    .testTarget(
      name: "ThingsLibraryTests",
      dependencies: ["ThingsLibrary"]
    ),
  ]
)
