// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimeTracker",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "TimeTracker",
            targets: ["TimeTracker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "TimeTracker",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
            ]
        ),
        .testTarget(
            name: "TimeTrackerTests",
            dependencies: [
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                "TimeTracker",
            ]
        ),
    ]
)
