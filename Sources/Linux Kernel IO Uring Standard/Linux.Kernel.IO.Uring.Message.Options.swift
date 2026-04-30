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

    extension ISO_9945.Kernel.IO.Uring {
        /// Types for io_uring MSG_RING operations (inter-ring messaging).
        public struct Message: Sendable {
            /// Flags controlling MSG_RING behavior.
            public struct Options: OptionSet, Sendable {
                public let rawValue: UInt32

                @inlinable
                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                /// Skip CQE on the source ring for this message.
                public static let cqeSkip = Options(rawValue: UInt32(IORING_MSG_RING_CQE_SKIP))

                /// Pass flags from the source SQE to the target CQE.
                public static let flagsPass = Options(rawValue: UInt32(IORING_MSG_RING_FLAGS_PASS))
            }
        }
    }

#endif
