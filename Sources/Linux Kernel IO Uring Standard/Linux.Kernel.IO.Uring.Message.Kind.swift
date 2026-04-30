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

    extension ISO_9945.Kernel.IO.Uring.Message {
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
    }

#endif
