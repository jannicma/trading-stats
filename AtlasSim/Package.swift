// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtlasSim",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AtlasSim",
            targets: ["AtlasSim"]),
    ],
    dependencies: [
        .package(path: "../AtlasCore"),
        .package(path: "../AtlasKit"),
        .package(path: "../AtlasVault"),
        .package(path: "../AtlasPlaybook")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AtlasSim",
            dependencies: [
                "AtlasCore",
                "AtlasKit",
                "AtlasVault",
                "AtlasPlaybook"
            ]
        ),
        .testTarget(
            name: "AtlasSimTests",
            dependencies: ["AtlasSim"]
        ),
    ]
)
