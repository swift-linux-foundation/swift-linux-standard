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
        /// Read operation opcodes.
        public struct Read {
            /// Read from file (pread-like, kernel 5.6+).
            public static let standard = Opcode(rawValue: 22)

            /// Vectored read (readv).
            public static let vectored = Opcode(rawValue: 1)

            /// Read from fixed buffers (readv with registered buffers).
            public static let fixed = Opcode(rawValue: 4)

            /// Read multishot (kernel 6.2+).
            public static let multishot = Opcode(rawValue: 49)

            /// Vectored read into registered buffers (kernel 6.x+).
            // WHY: Ideal path is `.read.vectored.fixed` but `.read.vectored` already
            // returns Opcode, not a namespace. Restructuring would break existing callers.
            public static let vectoredFixed = Opcode(rawValue: 60)
        }
    }

    extension Kernel.IO.Uring.Opcode {
        /// Access to read operation opcodes.
        public static var read: Kernel.IO.Uring.Read.Type { Kernel.IO.Uring.Read.self }
    }

#endif
