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

    extension Kernel.IO.Uring.Register {
        /// Ring registration opcodes.
        public struct Rings {
            /// Enables a disabled ring.
            ///
            /// Used after setting up a ring with `.rDisabled` flag.
            ///
            /// - Linux: `IORING_REGISTER_ENABLE_RINGS`
            public static let enable = Opcode(rawValue: 11)

            /// Ring descriptor registration sub-operations.
            public struct Descriptor {
                /// Registers ring file descriptors for fast access (kernel 5.18+).
                ///
                /// Allows using registered ring fds with `.registeredRing`
                /// enter flag, avoiding fd lookup overhead.
                ///
                /// - Linux: `IORING_REGISTER_RING_FDS`
                public static let register = Opcode(rawValue: 20)

                /// Unregisters ring file descriptors.
                ///
                /// - Linux: `IORING_UNREGISTER_RING_FDS`
                public static let unregister = Opcode(rawValue: 21)
            }

            /// Access to ring descriptor sub-operations.
            public static var descriptor: Descriptor.Type { Descriptor.self }
        }
    }

    extension Kernel.IO.Uring.Register.Opcode {
        /// Access to ring registration opcodes.
        public static var rings: Kernel.IO.Uring.Register.Rings.Type { Kernel.IO.Uring.Register.Rings.self }
    }

#endif
