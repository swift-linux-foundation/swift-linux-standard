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

    extension ISO_9945.Kernel.IO.Uring {
        /// Send operation opcodes.
        public struct Send {
            /// Send standard (kernel 5.6+).
            public static let standard = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 26)

            /// Send message (sendmsg).
            public static let message = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 9)

            /// Access to zero-copy send operations.
            public static var zero: Zero.Type { Zero.self }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to send zero-copy operation opcodes.
        public static var send: ISO_9945.Kernel.IO.Uring.Send.Type { ISO_9945.Kernel.IO.Uring.Send.self }
    }

#endif
