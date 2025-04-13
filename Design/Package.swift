// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Design",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Components",
            targets: ["Components"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [
                .product(name: "CacheService", package: "Core"),
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            swiftSettings: [
                .define("USE_UIKIT")
            ]
        )
    ]
)
