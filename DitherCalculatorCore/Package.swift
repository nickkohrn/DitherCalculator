// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DitherCalculatorCore",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "DitherCalculatorCore",
            targets: ["DitherCalculatorCore"]),
        .library(
            name: "Models",
            targets: ["Models"]),
    ],
    targets: [
        .target(
            name: "DitherCalculatorCore"),
        .testTarget(
            name: "DitherCalculatorCoreTests",
            dependencies: ["DitherCalculatorCore"]
        ),
        .target(
            name: "Models"),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]
        ),
    ]
)
