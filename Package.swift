// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Cookie",
    platforms: [
        .iOS(.v13)
     ],
    products: [
        .library(
            name: "Cookie",
            targets: ["Cookie"]),
    ],
    targets: [
        .target(
            name: "Cookie",
            dependencies: []),
        .testTarget(
            name: "CookieTests",
            dependencies: ["Cookie"]),
    ]
)
