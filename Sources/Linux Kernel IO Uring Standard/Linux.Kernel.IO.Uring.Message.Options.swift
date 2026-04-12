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

    extension Kernel.IO.Uring {
        /// Types for io_uring MSG_RING operations (inter-ring messaging).
        public struct Message: Sendable {
            /// The kind of message sent between rings.
            public enum Kind: UInt32, Sendable {
                /// Send arbitrary data to the target ring's CQ.
                ///
                /// - Linux: `IORING_MSG_DATA`
                case data = 0

                /// Send a file descriptor to the target ring.
                ///
                /// - Linux: `IORING_MSG_SEND_FD`
                case sendDescriptor = 1
            }

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
