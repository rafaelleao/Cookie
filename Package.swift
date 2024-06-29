// swift-tools-version:5.10
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
            name: "Extensions",
            dependencies: []
        ),
        .target(
            name: "Networking",
            dependencies: ["Extensions"]
        ),
        .target(
            name: "Cookie",
            dependencies: ["Networking"]
        ),
        .testTarget(
            name: "CookieTests",
            dependencies: ["Cookie"]
        )
    ]
)
