// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bump",
    products: [
        .executable(name: "bump", targets: ["Bump"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "6.7.0")),
    ],
    targets: [
        .target(
            name: "Bump",
            dependencies: ["xcodeproj"]),
        .testTarget(
            name: "BumpTests",
            dependencies: ["Bump"]),
    ]
)
