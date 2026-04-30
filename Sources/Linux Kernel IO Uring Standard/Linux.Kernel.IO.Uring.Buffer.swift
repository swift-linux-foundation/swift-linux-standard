// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

    public import Kernel_IO_Primitives

    extension ISO_9945.Kernel.IO.Uring {
        /// Namespace for buffer-related types and opcodes.
        ///
        /// Contains types for working with registered buffers and buffer
        /// groups (automatic buffer selection) in io_uring.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring/Buffer/Index``
        /// - ``Kernel/IO/Uring/Buffer/Group``
        /// - ``Kernel/IO/Uring/Register/Opcode/registerBuffers``
        public enum Buffer {
            /// Provide buffers to kernel.
            public static let provide = Opcode(rawValue: 31)

            /// Remove provided buffers.
            public static let remove = Opcode(rawValue: 32)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to buffer management operation opcodes.
        public static var buffer: ISO_9945.Kernel.IO.Uring.Buffer.Type { ISO_9945.Kernel.IO.Uring.Buffer.self }
    }

#endif
