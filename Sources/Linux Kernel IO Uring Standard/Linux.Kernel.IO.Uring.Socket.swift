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

public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {
        /// Socket operation opcodes.
        public struct Socket {
            /// Accept connection on socket.
            public static let accept = Opcode(rawValue: 13)

            /// Connect socket to address.
            public static let connect = Opcode(rawValue: 16)

            /// Send data on socket.
            public static let send = Opcode(rawValue: 26)

            /// Receive data from socket.
            public static let receive = Opcode(rawValue: 27)

            /// Access to message-oriented socket operations.
            public static var message: Message.Type { Message.self }

            /// Shutdown socket.
            public static let shutdown = Opcode(rawValue: 34)

            /// Socket operation.
            public static let create = Opcode(rawValue: 45)

            /// Bind socket to address (kernel 6.11+).
            public static let bind = Opcode(rawValue: 56)

            /// Listen on socket (kernel 6.11+).
            public static let listen = Opcode(rawValue: 57)

            /// Zero-copy receive (kernel 6.13+).
            // WHY: Compound name — the non-compound path would be `.receive.zero.copy`
            // via a dedicated Receive namespace (symmetric with Send.Zero). Deferred to
            // avoid scope creep; this provides immediate coverage.
            // TRACKING: Opcode 58 exceeds IORING_OP_LAST=58 in kernel 6.12.
            public static let receiveZeroCopy = Opcode(rawValue: 58)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to socket operation opcodes.
        public static var socket: ISO_9945.Kernel.IO.Uring.Socket.Type { ISO_9945.Kernel.IO.Uring.Socket.self }
    }

#endif
