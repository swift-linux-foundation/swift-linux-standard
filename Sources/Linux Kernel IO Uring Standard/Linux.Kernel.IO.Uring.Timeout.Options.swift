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
        /// Options for io_uring timeout operations.
        ///
        /// Combines modifier flags for timeout submissions. Clock source
        /// is provided separately via `Kernel.IO.Uring.Clock`.
        ///
        /// - `.absolute`: Interpret the timeout as a deadline, not a duration.
        /// - `.multishot`: Repeat the timeout automatically after each firing.
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Interpret the timeout specification as an absolute deadline
            /// rather than a relative duration.
            public static let absolute = Options(rawValue: UInt32(IORING_TIMEOUT_ABS))

            /// Repeat the timeout automatically. Each firing produces a CQE
            /// with `IORING_CQE_F_MORE`; the timeout remains active until
            /// explicitly removed.
            public static let multishot = Options(rawValue: UInt32(IORING_TIMEOUT_MULTISHOT))
        }
    }

#endif
