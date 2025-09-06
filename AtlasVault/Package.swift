// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtlasVault",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AtlasVault",
            targets: ["AtlasVault"]),
    ],
    dependencies: [
        .package(path: "../AtlasCore"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.6.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AtlasVault",
            dependencies: [
                "AtlasCore",
                .product(name: "GRDB", package: "GRDB.swift")
            ]
        ),
        .testTarget(
            name: "AtlasVaultTests",
            dependencies: ["AtlasVault"]
        ),
    ]
)
