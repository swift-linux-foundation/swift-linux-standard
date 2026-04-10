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

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.Timeout {
        /// Flags for io_uring timeout operations.
        ///
        /// Controls how the kernel interprets timeout values and
        /// which clock source to use.
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Timeout value is absolute, not relative.
            public static let absolute = Options(rawValue: UInt32(IORING_TIMEOUT_ABS))

            /// Update an existing timeout.
            public static let update = Options(rawValue: UInt32(IORING_TIMEOUT_UPDATE))

            /// Use CLOCK_BOOTTIME instead of CLOCK_MONOTONIC.
            public static let boottime = Options(rawValue: UInt32(IORING_TIMEOUT_BOOTTIME))

            /// Use CLOCK_REALTIME instead of CLOCK_MONOTONIC.
            public static let realtime = Options(rawValue: UInt32(IORING_TIMEOUT_REALTIME))

            /// Update a linked timeout.
            public static let linkUpdate = Options(rawValue: UInt32(IORING_LINK_TIMEOUT_UPDATE))

            /// Report timeout expiry as success (res=0), not -ETIME.
            public static let etimeSuccess = Options(rawValue: UInt32(IORING_TIMEOUT_ETIME_SUCCESS))

            /// Repeating timeout (multishot).
            public static let multishot = Options(rawValue: UInt32(IORING_TIMEOUT_MULTISHOT))
        }
    }

#endif
