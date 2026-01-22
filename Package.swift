// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-linux-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
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
        .library(
            name: "Linux Memory Primitives",
            targets: ["Linux Memory Primitives"]
        )
    ],
    dependencies: [
        .package(path: "../swift-kernel-primitives"),
        .package(path: "../swift-loader-primitives"),
        .package(path: "../../swift-standards/swift-iso-9945"),
        // SDG(wraps): Linux syscalls wrap errno
        // .package(path: "../swift-error-primitives"),
    ],
    targets: [
        .target(
            name: "Linux Primitives",
            dependencies: []
        ),
        .target(
            name: "CLinuxKernelShim",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("uuid", .when(platforms: [.linux]))
            ]
        ),
        .target(
            name: "CLinuxMemoryShim",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("dl", .when(platforms: [.linux]))
            ]
        ),
        .target(
            name: "Linux Kernel Primitives",
            dependencies: [
                .target(name: "Linux Primitives"),
                .target(name: "CLinuxKernelShim", condition: .when(platforms: [.linux])),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "ISO 9945 Kernel", package: "swift-iso-9945")
            ]
        ),
        .target(
            name: "Linux Loader Primitives",
            dependencies: [
                .target(name: "Linux Primitives"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives")
            ]
        ),
        .target(
            name: "Linux Memory Primitives",
            dependencies: [
                .target(name: "Linux Primitives"),
                .target(name: "CLinuxMemoryShim", condition: .when(platforms: [.linux]))
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety()
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
