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
        /// Memory operation opcodes.
        public struct Memory {
            /// Memory advice.
            public static let madvise = Opcode(rawValue: 25)
        }
    }

    extension Kernel.IO.Uring.Opcode {
        /// Access to memory operation opcodes.
        public static var memory: Kernel.IO.Uring.Memory.Type { Kernel.IO.Uring.Memory.self }
    }

#endif
