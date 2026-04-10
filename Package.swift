// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-linux-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // MARK: - Kernel
        .library(
            name: "Linux Kernel Standard",
            targets: ["Linux Kernel Standard"]
        ),
        .library(
            name: "Linux Kernel Event Standard",
            targets: ["Linux Kernel Event Standard"]
        ),
        .library(
            name: "Linux Kernel IO Standard",
            targets: ["Linux Kernel IO Standard"]
        ),
        .library(
            name: "Linux Kernel IO Uring Standard",
            targets: ["Linux Kernel IO Uring Standard"]
        ),
        // MARK: - Other
        .library(
            name: "Linux Loader Standard",
            targets: ["Linux Loader Standard"]
        ),
        .library(
            name: "Linux Memory Standard",
            targets: ["Linux Memory Standard"]
        ),
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-kernel-primitives"),
        .package(path: "../../swift-primitives/swift-cpu-primitives"),
        .package(path: "../../swift-primitives/swift-loader-primitives"),
        .package(path: "../../swift-iso/swift-iso-9945"),
    ],
    targets: [

        // MARK: - Core
        .target(
            name: "Linux Standard Core",
            dependencies: []
        ),

        // MARK: - C Shims
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

        // MARK: - Kernel
        .target(
            name: "Linux Kernel Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "CLinuxKernelShim", condition: .when(platforms: [.linux])),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Memory Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Random Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Path Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Socket Primitives", package: "swift-kernel-primitives"),
                .product(name: "ISO 9945 Kernel", package: "swift-iso-9945"),
            ]
        ),

        // MARK: - Kernel Event
        .target(
            name: "Linux Kernel Event Standard",
            dependencies: [
                "Linux Kernel Standard",
                .product(name: "Kernel Event Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Time Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel IO
        .target(
            name: "Linux Kernel IO Standard",
            dependencies: [
                "Linux Kernel Standard",
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Memory Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel IO Uring
        .target(
            name: "Linux Kernel IO Uring Standard",
            dependencies: [
                "Linux Kernel IO Standard",
                "Linux Kernel Event Standard",
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Memory Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "CPU Primitives", package: "swift-cpu-primitives"),
                .product(name: "ISO 9945 Kernel", package: "swift-iso-9945"),
            ]
        ),

        // MARK: - Loader
        .target(
            name: "Linux Loader Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives")
            ]
        ),

        // MARK: - Memory
        .target(
            name: "Linux Memory Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "CLinuxMemoryShim", condition: .when(platforms: [.linux]))
            ]
        ),

        // MARK: - Tests
        .testTarget(
            name: "Linux Kernel Standard Tests",
            dependencies: [
                "Linux Kernel Standard",
                "Linux Kernel Event Standard",
                "Linux Kernel IO Uring Standard",
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Event Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Memory Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Primitives Test Support", package: "swift-kernel-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
