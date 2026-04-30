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

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Ring operation opcodes.
        public struct Ring {
            /// Send message between rings.
            public static let msg = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 40)

            /// Uring command.
            public static let cmd = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 46)

            /// 128-byte uring command (kernel 6.13+).
            // TRACKING: Opcode 64 exceeds IORING_OP_LAST=58 in kernel 6.12.
            public static let cmd128 = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 64)
        }

        /// Access to ring operation opcodes.
        public static var ring: Ring.Type { Ring.self }
    }

#endif
