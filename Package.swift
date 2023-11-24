// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HeadwayBookPlayerFeature",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HeadwayBookPlayerFeature",
            targets: ["HeadwayBookPlayerFeature"]),
        .library(
            name: "ChapterRepositoryClient",
            targets: ["ChapterRepositoryClient"]),
        .library(
            name: "DateFormatterClient",
            targets: ["DateFormatterClient"]),
        .library(
            name: "FeedbackGeneratorClient",
            targets: ["FeedbackGeneratorClient"]),
        .library(
            name: "PlayerClient",
            targets: ["PlayerClient"]),
        .library(
            name: "SharedModels",
            targets: ["SharedModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HeadwayBookPlayerFeature",
        dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            "SharedModels",
            "ChapterRepositoryClient",
            "DateFormatterClient",
            "PlayerClient",
            "FeedbackGeneratorClient",
        ]),
        .testTarget(
            name: "HeadwayBookPlayerFeatureTests",
            dependencies: ["HeadwayBookPlayerFeature"]),
        .target(
            name: "ChapterRepositoryClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "SharedModels"
            ]),
        .target(
            name: "DateFormatterClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ]),
        .target(
            name: "FeedbackGeneratorClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ]),
        .target(
            name: "PlayerClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ]),
        .target(name: "SharedModels")
    ]
)
