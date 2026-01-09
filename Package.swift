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
    ],
    dependencies: [
        .package(path: "../swift-kernel-primitives"),
        .package(path: "../swift-test-support-primitives"),
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
        .testTarget(
            name: "Linux Kernel Primitives Tests",
            dependencies: [
                "Linux Kernel Primitives",
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "Test Support Primitives", package: "swift-test-support-primitives"),
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
