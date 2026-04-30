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

    extension ISO_9945.Kernel.IO.Uring {
        /// Memory operation opcodes.
        public struct Memory {
            /// Memory advice.
            public static let madvise = Opcode(rawValue: 25)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to memory operation opcodes.
        public static var memory: ISO_9945.Kernel.IO.Uring.Memory.Type { ISO_9945.Kernel.IO.Uring.Memory.self }
    }

#endif
