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
        .library(name: "Linux Kernel File Standard", targets: ["Linux Kernel File Standard"]),
        .library(name: "Linux Kernel Pipe Standard", targets: ["Linux Kernel Pipe Standard"]),
        .library(name: "Linux Kernel Socket Standard", targets: ["Linux Kernel Socket Standard"]),
        .library(name: "Linux Kernel Memory Standard", targets: ["Linux Kernel Memory Standard"]),
        .library(name: "Linux Kernel Descriptor Standard", targets: ["Linux Kernel Descriptor Standard"]),
        .library(name: "Linux Kernel Futex Standard", targets: ["Linux Kernel Futex Standard"]),
        .library(name: "Linux Kernel System Standard", targets: ["Linux Kernel System Standard"]),
        .library(name: "Linux Kernel Event Standard", targets: ["Linux Kernel Event Standard"]),
        .library(name: "Linux Kernel IO Standard", targets: ["Linux Kernel IO Standard"]),
        .library(name: "Linux Kernel IO Uring Standard", targets: ["Linux Kernel IO Uring Standard"]),
        // MARK: - Other
        .library(name: "Linux Loader Standard", targets: ["Linux Loader Standard"]),
        .library(name: "Linux Memory Standard", targets: ["Linux Memory Standard"]),
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-algebra-primitives"),
        .package(path: "../../swift-primitives/swift-kernel-primitives"),
        .package(path: "../../swift-primitives/swift-cpu-primitives"),
        .package(path: "../../swift-primitives/swift-dimension-primitives"),
        .package(path: "../../swift-primitives/swift-loader-primitives"),
        .package(path: "../../swift-primitives/swift-string-primitives"),
        .package(path: "../../swift-primitives/swift-system-primitives"),
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-witness-primitives"),
        .package(path: "../../swift-primitives/swift-error-primitives"),
        .package(path: "../../swift-primitives/swift-random-primitives"),
        .package(path: "../../swift-primitives/swift-path-primitives"),
        .package(path: "../../swift-primitives/swift-memory-primitives"),
        .package(path: "../../swift-iso/swift-iso-9945"),
    ],
    targets: [

        // MARK: - Core
        .target(
            name: "Linux Standard Core",
            dependencies: [
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "ISO 9945 Core", package: "swift-iso-9945"),
            ]
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

        // MARK: - Kernel File
        .target(
            name: "Linux Kernel File Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "CLinuxKernelShim", condition: .when(platforms: [.linux])),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
                .product(name: "ISO 9945 Kernel File", package: "swift-iso-9945"),
            ]
        ),
        // MARK: - Kernel Pipe
        .target(
            name: "Linux Kernel Pipe Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "CLinuxKernelShim", condition: .when(platforms: [.linux])),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                            .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Random Primitives", package: "swift-random-primitives"),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
                .product(name: "Algebra Primitives Core", package: "swift-algebra-primitives"),
            ]
        ),
        // MARK: - Kernel Socket
        .target(
            name: "Linux Kernel Socket Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .product(name: "ISO 9945 Kernel Socket Address", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Socket", package: "swift-iso-9945"),
            ]
        ),
        // MARK: - Kernel Memory
        .target(
            name: "Linux Kernel Memory Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "ISO 9945 Kernel Memory", package: "swift-iso-9945"),
                            .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Random Primitives", package: "swift-random-primitives"),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
            ]
        ),
        // MARK: - Kernel Descriptor
        .target(
            name: "Linux Kernel Descriptor Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "CLinuxKernelShim", condition: .when(platforms: [.linux])),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                            .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Random Primitives", package: "swift-random-primitives"),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
            ]
        ),
        // MARK: - Kernel Futex
        .target(
            name: "Linux Kernel Futex Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Random Primitives", package: "swift-random-primitives"),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
            ]
        ),
        // MARK: - Kernel System
        .target(
            name: "Linux Kernel System Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "CLinuxKernelShim", condition: .when(platforms: [.linux])),
                .product(name: "System Primitives", package: "swift-system-primitives"),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
                .product(name: "ISO 9945 Kernel Signal", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Process", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel System", package: "swift-iso-9945"),
                .product(name: "Random Primitives", package: "swift-random-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
                .product(name: "Kernel Time Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Event
        .target(
            name: "Linux Kernel Event Standard",
            dependencies: [
                "Linux Standard Core",
                .target(name: "CLinuxKernelShim", condition: .when(platforms: [.linux])),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Event Primitives", package: "swift-kernel-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Kernel Time Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel IO
        .target(
            name: "Linux Kernel IO Standard",
            dependencies: [
                "Linux Standard Core",
                "Linux Kernel File Standard",
                "Linux Kernel Descriptor Standard",
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel IO Uring
        .target(
            name: "Linux Kernel IO Uring Standard",
            dependencies: [
                "Linux Kernel IO Standard",
                "Linux Kernel Event Standard",
                "Linux Kernel File Standard",
                "Linux Kernel Pipe Standard",
                "Linux Kernel Futex Standard",
                "Linux Kernel Socket Standard",
                "Linux Kernel System Standard",
                "Linux Kernel Memory Standard",
                .product(name: "ISO 9945 Kernel Signal", package: "swift-iso-9945"),
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
                .product(name: "CPU Primitives", package: "swift-cpu-primitives"),
                .product(name: "ISO 9945 Kernel File", package: "swift-iso-9945"),
            ]
        ),

        // MARK: - Loader
        .target(
            name: "Linux Loader Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "CLinuxKernelShim", condition: .when(platforms: [.linux])),
                .product(name: "Loader Primitives", package: "swift-loader-primitives"),
                .product(name: "String Primitives", package: "swift-string-primitives")
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
                "Linux Kernel File Standard",
                "Linux Kernel Pipe Standard",
                "Linux Kernel Socket Standard",
                "Linux Kernel Memory Standard",
                "Linux Kernel Descriptor Standard",
                "Linux Kernel Futex Standard",
                "Linux Kernel System Standard",
                "Linux Kernel Event Standard",
                "Linux Kernel IO Uring Standard",
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Event Primitives", package: "swift-kernel-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
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
