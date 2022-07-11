// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "cleema-kit",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "GoalFeature",
            targets: ["GoalFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.38.2")
    ],
    targets: [
        .target(
            name: "GoalFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]),
        .testTarget(
            name: "GoalFeatureTests",
            dependencies: ["GoalFeature"]),
    ]
)
