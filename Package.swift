// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Optimization",
    products: [
        .library(name: "Optimization", targets: ["Optimization"]),
    ],
    targets: [
        .target(name: "Optimization"),
        .testTarget(name: "OptimizationTests", dependencies: ["Optimization"]),
        .executableTarget(name: "Benchmark", dependencies: ["Optimization"])
    ]
)
