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

    extension Kernel.IO.Uring.Poll {
        /// Options for io_uring poll operations.
        ///
        /// Controls trigger mode and multishot behavior for poll submissions.
        ///
        /// - `.level`: Level-triggered — fires while the condition holds.
        ///   Default (empty set) is edge-triggered — fires on state change.
        /// - `.multishot`: Produce a CQE on every event without resubmission.
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Level-triggered mode — fires while the condition holds.
            /// Default (absent) is edge-triggered — fires on state change.
            public static let level = Options(rawValue: UInt32(IORING_POLL_ADD_LEVEL))

            /// Multishot mode — produces CQEs on every event without
            /// requiring resubmission. Check `IORING_CQE_F_MORE` on each
            /// CQE; resubmit when absent.
            public static let multishot = Options(rawValue: UInt32(IORING_POLL_ADD_MULTI))
        }
    }

    extension Kernel.IO.Uring.Poll.Trigger {
        /// Convert this trigger mode to the equivalent poll option.
        @usableFromInline
        var option: Kernel.IO.Uring.Poll.Options {
            switch self {
            case .edge: []
            case .level: .level
            }
        }
    }

#endif
