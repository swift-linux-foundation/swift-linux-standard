// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)
    extension ISO_9945.Kernel.IO.Uring.Socket {
        /// Message-oriented socket operations.
        public struct Message {
            /// Send message on socket (sendmsg).
            public static let send = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 9)

            /// Receive message from socket (recvmsg).
            public static let receive = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 10)
        }
    }

#endif
