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
            public static let enable = Opcode(rawValue: 12)

            /// Access to ring descriptor sub-operations.
            public static var descriptor: Descriptor.Type { Descriptor.self }
        }
    }

    extension Kernel.IO.Uring.Register.Opcode {
        /// Access to ring registration opcodes.
        public static var rings: Kernel.IO.Uring.Register.Rings.Type { Kernel.IO.Uring.Register.Rings.self }
    }

#endif
