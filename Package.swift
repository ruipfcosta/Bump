// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bump",
    products: [
        .executable(name: "bump", targets: ["Bump"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/xcodeproj.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "Bump",
            dependencies: ["XcodeProj"]),
        .testTarget(
            name: "BumpTests",
            dependencies: ["Bump"]),
    ]
)
