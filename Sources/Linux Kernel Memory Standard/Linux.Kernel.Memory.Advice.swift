// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

public import Kernel_Memory_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Memory {
    /// Memory access pattern advice for madvise(2).
    public struct Advice: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension Kernel.Memory.Advice {
    /// No special treatment (default).
    public static let normal = Self(rawValue: UInt32(MADV_NORMAL))

    /// Expect random access.
    public static let random = Self(rawValue: UInt32(MADV_RANDOM))

    /// Expect sequential access.
    public static let sequential = Self(rawValue: UInt32(MADV_SEQUENTIAL))

    /// Pages will be accessed in the near future.
    public static let willNeed = Self(rawValue: UInt32(MADV_WILLNEED))

    /// Pages will not be accessed in the near future.
    public static let dontNeed = Self(rawValue: UInt32(MADV_DONTNEED))

    /// Pages can be freed by the kernel when under memory pressure.
    public static let free = Self(rawValue: UInt32(MADV_FREE))

    /// Remove the pages entirely (for shared/tmpfs mappings).
    public static let remove = Self(rawValue: UInt32(MADV_REMOVE))
}

#endif
