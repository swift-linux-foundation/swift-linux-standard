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

public import Kernel_IO_Primitives

extension Kernel.IO.Uring.Timeout {
    /// Kernel timespec for io_uring timeout operations.
    ///
    /// Layout-compatible with `struct __kernel_timespec` from
    /// `<linux/time_types.h>`. An `UnsafePointer<Specification>` may be
    /// passed directly to kernel interfaces that expect
    /// `struct __kernel_timespec *`.
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
