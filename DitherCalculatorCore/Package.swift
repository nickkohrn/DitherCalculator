// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DitherCalculatorCore",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "CoreUI",
            targets: ["CoreUI"]),
        .library(
            name: "FoundationExtensions",
            targets: ["FoundationExtensions"]),
        .library(
            name: "Models",
            targets: ["Models"]),
        .library(
            name: "Syncing",
            targets: ["Syncing"]),
    ],
    targets: [
        .target(
            name: "CoreUI"),
        .target(
            name: "FoundationExtensions"),
        .testTarget(
            name: "FoundationExtensionsTests",
            dependencies: ["FoundationExtensions"]),
        .target(
            name: "Models",
            dependencies: ["FoundationExtensions"]),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]),
        .target(
            name: "Syncing",
            dependencies: ["Models"]),
        .testTarget(
            name: "TestUtilities",
            dependencies: ["Models",
                           "Syncing"]),
    ]
)
