// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimeTrackerAPI",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "TimeTrackerAPI",
            targets: ["TimeTrackerAPI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "TimeTrackerAPI",
            dependencies: [
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            ]
        ),
        .testTarget(
            name: "TimeTrackerAPITests",
            dependencies: [
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                "TimeTrackerAPI",
            ]
        ),
    ]
)
