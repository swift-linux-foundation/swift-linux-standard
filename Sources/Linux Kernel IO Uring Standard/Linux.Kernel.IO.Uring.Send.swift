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
    public import Kernel_Descriptor_Primitives
    public import Kernel_Error_Primitives
    public import Kernel_Memory_Primitives
    public import Kernel_File_Primitives

    extension Kernel.IO.Uring {
        /// Send operation opcodes.
        public struct Send {
            /// Send standard (kernel 5.6+).
            public static let standard = Kernel.IO.Uring.Opcode(rawValue: 26)

            /// Send message (sendmsg).
            public static let message = Kernel.IO.Uring.Opcode(rawValue: 9)

            /// Access to zero-copy send operations.
            public static var zero: Zero.Type { Zero.self }
        }
    }

    extension Kernel.IO.Uring.Opcode {
        /// Access to send zero-copy operation opcodes.
        public static var send: Kernel.IO.Uring.Send.Type { Kernel.IO.Uring.Send.self }
    }

#endif
