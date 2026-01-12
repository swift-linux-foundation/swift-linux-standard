// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-linux-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Linux Primitives",
            targets: ["Linux Primitives"]
        ),
        .library(
            name: "Linux Kernel Primitives",
            targets: ["Linux Kernel Primitives"]
        ),
        .library(
            name: "Linux Loader Primitives",
            targets: ["Linux Loader Primitives"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-kernel-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-loader-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-test-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-testing-extras.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "Linux Primitives",
            dependencies: []
        ),
        .target(
            name: "CLinuxKernelShim",
            dependencies: []
        ),
        .target(
            name: "Linux Kernel Primitives",
            dependencies: [
                .target(name: "Linux Primitives"),
                .target(name: "CLinuxKernelShim", condition: .when(platforms: [.linux])),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
            ]
        ),
        .target(
            name: "Linux Loader Primitives",
            dependencies: [
                .target(name: "Linux Primitives"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives"),
            ]
        ),
        .testTarget(
            name: "Linux Kernel Primitives Tests",
            dependencies: [
                "Linux Kernel Primitives",
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "Test Primitives", package: "swift-test-primitives"),
                .product(name: "Testing Extras", package: "swift-testing-extras"),
            ],
            path: "Tests/Linux Kernel Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
