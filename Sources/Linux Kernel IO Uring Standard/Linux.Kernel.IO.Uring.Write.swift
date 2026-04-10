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
        /// Write operation opcodes.
        public struct Write {
            /// Write to file (pwrite-like, kernel 5.6+).
            public static let standard = Opcode(rawValue: 23)

            /// Vectored write (writev).
            public static let vectored = Opcode(rawValue: 2)

            /// Write to fixed buffers (writev with registered buffers).
            public static let fixed = Opcode(rawValue: 5)

            /// Vectored write from registered buffers (kernel 6.x+).
            // WHY: Ideal path is `.write.vectored.fixed` but `.write.vectored` already
            // returns Opcode, not a namespace. Restructuring would break existing callers.
            public static let vectoredFixed = Opcode(rawValue: 61)
        }
    }

    extension Kernel.IO.Uring.Opcode {
        /// Access to write operation opcodes.
        public static var write: Kernel.IO.Uring.Write.Type { Kernel.IO.Uring.Write.self }
    }

#endif
