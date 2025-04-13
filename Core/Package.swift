// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CacheService",
            targets: ["CacheService"]),
        .library(
            name: "NetworkService",
            targets: ["NetworkService"]),
        .library(name: "ApiModels", targets: ["ApiModels"]),
        .library(
            name: "ViewedStoriesService",
            targets: ["ViewedStoriesService"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ApiModels"
        ),
        .target(
            name: "CacheService",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "NetworkService",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "ApiModels"
            ]
        ),
        .target(
            name: "ViewedStoriesService",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                "ApiModels"
            ]
        )
    ]
)
