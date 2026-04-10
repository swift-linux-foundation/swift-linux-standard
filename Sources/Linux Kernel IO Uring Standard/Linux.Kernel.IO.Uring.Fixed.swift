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
        /// Fixed fd operation opcodes.
        public struct Fixed {
            /// Fixed fd install (kernel 6.7+).
            public static let fdInstall = Opcode(rawValue: 54)
        }
    }

    extension Kernel.IO.Uring.Opcode {
        /// Access to fixed fd operation opcodes.
        public static var fixed: Kernel.IO.Uring.Fixed.Type { Kernel.IO.Uring.Fixed.self }
    }

#endif
