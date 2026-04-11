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

public import Kernel_File_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.File {
    /// File access pattern advice for fadvise(2).
    public struct Advice: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension Kernel.File.Advice {
    /// No special treatment (default).
    public static let normal = Self(rawValue: UInt32(POSIX_FADV_NORMAL))

    /// Expect random access.
    public static let random = Self(rawValue: UInt32(POSIX_FADV_RANDOM))

    /// Expect sequential access.
    public static let sequential = Self(rawValue: UInt32(POSIX_FADV_SEQUENTIAL))

    /// Data will be accessed in the near future.
    public static let willNeed = Self(rawValue: UInt32(POSIX_FADV_WILLNEED))

    /// Data will not be accessed in the near future.
    public static let dontNeed = Self(rawValue: UInt32(POSIX_FADV_DONTNEED))

    /// Data will be accessed only once.
    public static let noReuse = Self(rawValue: UInt32(POSIX_FADV_NOREUSE))
}

#endif
