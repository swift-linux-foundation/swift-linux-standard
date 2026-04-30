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

    extension ISO_9945.Kernel.IO.Uring.Socket {
        /// Socket uring_cmd sub-operations.
        ///
        /// Used with `IORING_OP_URING_CMD` on socket file descriptors
        /// to perform socket-specific commands.
        public struct Command: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Socket.Command {
        /// Query the number of bytes in the receive queue.
        ///
        /// - Linux: `SOCKET_URING_OP_SIOCINQ`
        public static let inputQueue = Self(rawValue: 0)

        /// Query the number of bytes in the send queue.
        ///
        /// - Linux: `SOCKET_URING_OP_SIOCOUTQ`
        public static let outputQueue = Self(rawValue: 1)

        /// Get a socket option.
        ///
        /// - Linux: `SOCKET_URING_OP_GETSOCKOPT`
        public static let getOption = Self(rawValue: 2)

        /// Set a socket option.
        ///
        /// - Linux: `SOCKET_URING_OP_SETSOCKOPT`
        public static let setOption = Self(rawValue: 3)
    }

#endif
