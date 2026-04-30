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

    extension ISO_9945.Kernel.IO.Uring.Register.Buffers {
        /// Provided buffer ring sub-operations.
        public struct Provided {
            /// Registers a provided buffer ring (kernel 5.19+).
            ///
            /// Enables automatic buffer selection from a ring of
            /// pre-provided buffers. More efficient than the legacy
            /// `PROVIDE_BUFFERS` opcode.
            ///
            /// - Linux: `IORING_REGISTER_PBUF_RING`
            public static let register = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 22)

            /// Unregisters a provided buffer ring.
            ///
            /// - Linux: `IORING_UNREGISTER_PBUF_RING`
            public static let unregister = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 23)

            /// Queries provided buffer ring status (kernel 6.4+).
            ///
            /// - Linux: `IORING_REGISTER_PBUF_STATUS`
            public static let status = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 26)
        }
    }

#endif
