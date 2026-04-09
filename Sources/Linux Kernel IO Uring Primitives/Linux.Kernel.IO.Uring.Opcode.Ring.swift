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

    extension Kernel.IO.Uring.Opcode {
        /// Ring operation opcodes.
        public struct Ring {
            /// Send message between rings.
            public static let msg = Kernel.IO.Uring.Opcode(rawValue: 40)

            /// Uring command.
            public static let cmd = Kernel.IO.Uring.Opcode(rawValue: 46)
        }

        /// Access to ring operation opcodes.
        public static var ring: Ring.Type { Ring.self }
    }

#endif
