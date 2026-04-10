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
        /// Flags for io_uring poll operations.
        public struct Flags: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Multishot poll — produces CQEs on every event without resubmission.
            public static let multishot = Flags(rawValue: UInt32(IORING_POLL_ADD_MULTI))

            /// Update the events mask of an existing poll.
            public static let updateEvents = Flags(rawValue: UInt32(IORING_POLL_UPDATE_EVENTS))

            /// Update the user_data of an existing poll.
            public static let updateUserData = Flags(rawValue: UInt32(IORING_POLL_UPDATE_USER_DATA))

            /// Level-triggered (not edge-triggered).
            public static let level = Flags(rawValue: UInt32(IORING_POLL_ADD_LEVEL))
        }
    }

#endif
