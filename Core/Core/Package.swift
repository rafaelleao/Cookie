// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
     ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Core",
            dependencies: [])
    ]
)
