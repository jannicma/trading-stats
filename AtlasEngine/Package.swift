// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtlasEngine",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AtlasEngine",
            targets: ["AtlasEngine"]),
    ],
    dependencies: [
        .package(path: "../AtlasCore"),
        .package(path: "../AtlasKit"),
        .package(path: "../AtlasPlaybook")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AtlasEngine",
            dependencies: [
                "AtlasCore",
                "AtlasKit",
                "AtlasPlaybook"
            ]
        ),
        .testTarget(
            name: "AtlasEngineTests",
            dependencies: ["AtlasEngine"]
        ),
    ]
)
