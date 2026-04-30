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


extension Linux.Kernel.Time {
    /// Binary-compatible wrapper for `struct __kernel_timespec`.
    ///
    /// Layout: two `Int64` fields matching `<linux/time_types.h>`.
    /// Used by multiple Linux kernel subsystems — io_uring timeouts,
    /// futex, `clock_nanosleep`, `pselect6`, `ppoll`, `io_pgetevents`.
    ///
    /// An `UnsafePointer<Specification>` may be passed directly to any
    /// kernel interface that expects `struct __kernel_timespec *`.
    public struct Specification: Sendable, Equatable, Hashable {
        /// Seconds component.
        public var seconds: Int64

        /// Nanoseconds component (0 ..< 1_000_000_000).
        public var nanoseconds: Int64

        /// Creates a timeout specification.
        ///
        /// - Parameters:
        ///   - seconds: Seconds component.
        ///   - nanoseconds: Nanoseconds component.
        public init(seconds: Int64, nanoseconds: Int64) {
            self.seconds = seconds
            self.nanoseconds = nanoseconds
        }
    }
}

#endif
