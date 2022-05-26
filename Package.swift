// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Cookie",
    platforms: [
        .iOS(.v14)
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
