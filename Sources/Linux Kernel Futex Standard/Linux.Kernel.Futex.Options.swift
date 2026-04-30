// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

public import Error_Primitives
public import Kernel_File_Primitives
public import Memory_Primitives
public import Path_Primitives

// MARK: - Linux Futex Flags

extension Kernel.Futex {
    /// Flags for futex operations.
    ///
    /// Wraps FUTEX_* constants from `<linux/futex.h>`.
    /// Values defined as raw integers since linux/futex.h is not
    /// available via SwiftGlibc.
    public struct Options: OptionSet, Sendable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// Use the private futex fast path (process-private futex).
        public static let privateFlag = Self(rawValue: 128) // FUTEX_PRIVATE_FLAG

        /// Use the clock realtime for timeout.
        public static let clockRealtime = Self(rawValue: 256) // FUTEX_CLOCK_REALTIME
    }
}

#endif
