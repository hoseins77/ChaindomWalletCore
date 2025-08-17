// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChaindomWalletCore",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ChaindomWalletCore",
            targets: ["ChaindomWalletCore"]),
    ],
    dependencies: [
        // Add your dependency here
        .package(url: "https://github.com/21-DOT-DEV/swift-secp256k1", exact: "0.18.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ChaindomWalletCore",
            dependencies: [
                .product(name: "secp256k1", package: "swift-secp256k1"),
                .product(name: "BigInt", package: "BigInt"),
            ]),
        
        .testTarget(
            name: "CoreTests",
            dependencies: ["ChaindomWalletCore"]
        ),
    ]
)
