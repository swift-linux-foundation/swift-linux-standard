// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux project authors
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
        /// Namespace for io_uring_register related types.
        ///
        /// Contains opcodes and types for registering resources with io_uring.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring/Register/Opcode``
        public enum Register {}
    }

#endif
