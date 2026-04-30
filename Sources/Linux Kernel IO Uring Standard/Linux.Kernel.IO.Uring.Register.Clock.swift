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

    extension ISO_9945.Kernel.IO.Uring.Register {
        /// Clock source registration opcodes.
        public struct Clock {
            /// Registers the default clock source for the ring (kernel 6.10+).
            ///
            /// Sets which clock (monotonic, boottime, realtime) is used
            /// by default for timeout operations on this ring.
            ///
            /// - Linux: `IORING_REGISTER_CLOCK`
            public static let register = Opcode(rawValue: 29)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {
        /// Access to clock registration opcodes.
        public static var clock: ISO_9945.Kernel.IO.Uring.Register.Clock.Type { ISO_9945.Kernel.IO.Uring.Register.Clock.self }
    }

#endif
