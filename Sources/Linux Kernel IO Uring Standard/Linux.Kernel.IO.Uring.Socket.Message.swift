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
    public import Kernel_IO_Primitives
    extension Kernel.IO.Uring.Socket {
        /// Message-oriented socket operations.
        public struct Message {
            /// Send message on socket (sendmsg).
            public static let send = Kernel.IO.Uring.Opcode(rawValue: 9)

            /// Receive message from socket (recvmsg).
            public static let receive = Kernel.IO.Uring.Opcode(rawValue: 10)
        }
    }

#endif
