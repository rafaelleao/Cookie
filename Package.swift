// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "Cookie",
    platforms: [
        .iOS(.v16),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Cookie",
            targets: ["Cookie"]
        )
    ],
    targets: [
        .target(
            name: "Cookie",
            dependencies: []
        ),
        .testTarget(
            name: "CookieTests",
            dependencies: ["Cookie"]
        )
    ]
)
