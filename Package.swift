// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-linux-standard",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(name: "Linux Kernel File Standard", targets: ["Linux Kernel File Standard"]),
        .library(name: "Linux Kernel Pipe Standard", targets: ["Linux Kernel Pipe Standard"]),
        .library(name: "Linux Kernel Socket Standard", targets: ["Linux Kernel Socket Standard"]),
        .library(name: "Linux Kernel Memory Standard", targets: ["Linux Kernel Memory Standard"]),
        .library(
            name: "Linux Kernel Descriptor Standard",
            targets: ["Linux Kernel Descriptor Standard"]
        ),
        .library(name: "Linux Kernel Futex Standard", targets: ["Linux Kernel Futex Standard"]),
        .library(name: "Linux Kernel System Standard", targets: ["Linux Kernel System Standard"]),
        .library(name: "Linux Kernel Event Standard", targets: ["Linux Kernel Event Standard"]),
        .library(name: "Linux Kernel Process Standard", targets: ["Linux Kernel Process Standard"]),
        .library(name: "Linux Kernel Timer Standard", targets: ["Linux Kernel Timer Standard"]),
        .library(name: "Linux Kernel Signal Standard", targets: ["Linux Kernel Signal Standard"]),
        .library(name: "Linux Kernel IO Standard", targets: ["Linux Kernel IO Standard"]),
        .library(
            name: "Linux Kernel IO Uring Standard",
            targets: ["Linux Kernel IO Uring Standard"]
        ),

        .library(name: "Linux Loader Standard", targets: ["Linux Loader Standard"]),
        .library(name: "Linux Memory Standard", targets: ["Linux Memory Standard"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-pair.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cpu.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dimension.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-loader-vocabulary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-string.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-system.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-error.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-random.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-path.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-map.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-molecules/swift-binary.git", branch: "main"),
        .package(url: "https://github.com/swift-iso/swift-iso-9945.git", branch: "main"),
    ],
    targets: [

        .target(
            name: "Linux Standard Core",
            dependencies: [
                .product(name: "ISO 9945 Core", package: "swift-iso-9945")
            ]
        ),

        .target(
            name: "Linux Kernel Shims",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("uuid", .when(platforms: [.linux]))
            ]
        ),
        .target(
            name: "Linux Memory Shims",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("dl", .when(platforms: [.linux]))
            ]
        ),

        .target(
            name: "Linux Kernel File Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel Shims", condition: .when(platforms: [.linux])),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Path", package: "swift-path"),
                .product(name: "ISO 9945 Kernel File", package: "swift-iso-9945"),
            ]
        ),

        .target(
            name: "Linux Kernel Pipe Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel Shims", condition: .when(platforms: [.linux])),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Random", package: "swift-random"),
                .product(name: "Path", package: "swift-path"),
                .product(name: "Pair", package: "swift-pair"),
            ]
        ),

        .target(
            name: "Linux Kernel Socket Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .product(name: "ISO 9945 Kernel Socket Address", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Socket", package: "swift-iso-9945"),
            ]
        ),

        .target(
            name: "Linux Kernel Memory Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "ISO 9945 Kernel Memory", package: "swift-iso-9945"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Random", package: "swift-random"),
                .product(name: "Path", package: "swift-path"),
            ]
        ),

        .target(
            name: "Linux Kernel Descriptor Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel Shims", condition: .when(platforms: [.linux])),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Random", package: "swift-random"),
                .product(name: "Path", package: "swift-path"),
            ]
        ),

        .target(
            name: "Linux Kernel Futex Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Random", package: "swift-random"),
                .product(name: "Path", package: "swift-path"),
            ]
        ),

        .target(
            name: "Linux Kernel System Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel Shims", condition: .when(platforms: [.linux])),
                .product(name: "System", package: "swift-system"),
                .product(name: "ISO 9945 Kernel Signal", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Process", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel System", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Thread", package: "swift-iso-9945"),
                .product(name: "Random", package: "swift-random"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Path", package: "swift-path"),
            ]
        ),

        .target(
            name: "Linux Kernel Event Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel Shims", condition: .when(platforms: [.linux])),
                .product(name: "Error", package: "swift-error"),
                .product(name: "ISO 9945 Kernel Time", package: "swift-iso-9945"),
            ]
        ),

        .target(
            name: "Linux Kernel Process Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel Shims", condition: .when(platforms: [.linux])),
                .product(name: "Error", package: "swift-error"),
                .product(name: "ISO 9945 Kernel Process", package: "swift-iso-9945"),
            ]
        ),

        .target(
            name: "Linux Kernel Timer Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel Shims", condition: .when(platforms: [.linux])),
                .product(name: "Error", package: "swift-error"),
            ]
        ),

        .target(
            name: "Linux Kernel Signal Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel Shims", condition: .when(platforms: [.linux])),
                .product(name: "Error", package: "swift-error"),
                .product(name: "ISO 9945 Kernel Signal", package: "swift-iso-9945"),
            ]
        ),

        .target(
            name: "Linux Kernel IO Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel File Standard"),
                .target(name: "Linux Kernel Descriptor Standard"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
            ]
        ),

        .target(
            name: "Linux Kernel IO Uring Standard",
            dependencies: [
                .target(name: "Linux Kernel IO Standard"),
                .target(name: "Linux Kernel Event Standard"),
                .target(name: "Linux Kernel File Standard"),
                .target(name: "Linux Kernel Pipe Standard"),
                .target(name: "Linux Kernel Futex Standard"),
                .target(name: "Linux Kernel Socket Standard"),
                .target(name: "Linux Kernel System Standard"),
                .target(name: "Linux Kernel Memory Standard"),
                .product(name: "ISO 9945 Kernel Signal", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Process", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Socket", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Socket Address", package: "swift-iso-9945"),
                .product(name: "Dimension", package: "swift-dimension"),
                .product(name: "Binary", package: "swift-binary"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "CPU", package: "swift-cpu"),
                .product(name: "Memory Map", package: "swift-memory-map"),
                .product(name: "ISO 9945 Kernel File", package: "swift-iso-9945"),
            ],
            swiftSettings: [.enableExperimentalFeature("LifetimeDependence")]
        ),

        .target(
            name: "Linux Loader Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Kernel Shims", condition: .when(platforms: [.linux])),
                .product(name: "Loader", package: "swift-loader-vocabulary"),
                .product(name: "String", package: "swift-string"),
                .product(name: "ISO 9945 Core", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Loader", package: "swift-iso-9945"),
            ]
        ),

        .target(
            name: "Linux Memory Standard",
            dependencies: [
                .target(name: "Linux Standard Core"),
                .target(name: "Linux Memory Shims", condition: .when(platforms: [.linux])),
            ]
        ),

        .testTarget(
            name: "Linux Kernel Standard Tests",
            dependencies: [
                .target(name: "Linux Kernel File Standard"),
                .target(name: "Linux Kernel Pipe Standard"),
                .target(name: "Linux Kernel Socket Standard"),
                .target(name: "Linux Kernel Memory Standard"),
                .target(name: "Linux Kernel Descriptor Standard"),
                .target(name: "Linux Kernel Futex Standard"),
                .target(name: "Linux Kernel System Standard"),
                .target(name: "Linux Kernel Event Standard"),
                .target(name: "Linux Kernel Process Standard"),
                .target(name: "Linux Kernel Timer Standard"),
                .target(name: "Linux Kernel Signal Standard"),
                .target(name: "Linux Kernel IO Uring Standard"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
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
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
