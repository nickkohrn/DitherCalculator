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
            name: "SaveConfig",
            targets: ["SaveConfig"]),
        .library(
            name: "Syncing",
            targets: ["Syncing"]),
    ],
    targets: [
        .target(
            name: "CoreUI",
            dependencies: ["FoundationExtensions",
                           "Models"]),
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
            name: "SaveConfig",
            dependencies: ["CoreUI",
                           "Models",
                           "Syncing"],
            path: "Sources/Features/SaveConfig"),
        .testTarget(
            name: "SaveConfigTests",
            dependencies: ["SaveConfig"],
            path: "Tests/Features/SaveConfigTests"),
        .target(
            name: "Syncing",
            dependencies: ["Models"]),
        .testTarget(
            name: "TestUtilities",
            dependencies: ["Models",
                           "Syncing"]),
    ]
)
