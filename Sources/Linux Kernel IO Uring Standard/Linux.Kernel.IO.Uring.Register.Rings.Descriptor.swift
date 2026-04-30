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

    extension ISO_9945.Kernel.IO.Uring.Register.Rings {
        /// Ring descriptor registration sub-operations.
        public struct Descriptor {
            /// Registers ring file descriptors for fast access (kernel 5.18+).
            ///
            /// Allows using registered ring fds with `.registeredRing`
            /// enter flag, avoiding fd lookup overhead.
            ///
            /// - Linux: `IORING_REGISTER_RING_FDS`
            public static let register = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 20)

            /// Unregisters ring file descriptors.
            ///
            /// - Linux: `IORING_UNREGISTER_RING_FDS`
            public static let unregister = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 21)
        }
    }

#endif
