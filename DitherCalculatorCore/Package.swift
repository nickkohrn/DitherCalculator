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
            name: "EditConfig",
            targets: ["EditConfig"]),
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
            name: "EditConfig",
            dependencies: ["CoreUI",
                           "Models",
                           "Syncing"],
            path: "Sources/Features/EditConfig"),
        .testTarget(
            name: "EditConfigTests",
            dependencies: ["EditConfig",
                           "TestUtilities"],
            path: "Tests/Features/EditConfigTests"),
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
            dependencies: ["SaveConfig",
                           "TestUtilities"],
            path: "Tests/Features/SaveConfigTests"),
        .target(
            name: "Syncing",
            dependencies: ["Models"]),
        .target(
            name: "TestUtilities",
            dependencies: ["Models",
                           "Syncing"],
            path: "Tests/TestUtilities"),
    ]
)
