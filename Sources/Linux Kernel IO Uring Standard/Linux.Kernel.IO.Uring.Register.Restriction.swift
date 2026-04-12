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

    extension Kernel.IO.Uring.Register {
        /// Restriction registration opcodes.
        public struct Restriction {
            /// Registers restrictions on the ring (kernel 5.10+).
            ///
            /// Limits which register operations and SQE opcodes/flags
            /// are permitted. Used for sandboxing.
            ///
            /// - Linux: `IORING_REGISTER_RESTRICTIONS`
            public static let register = Opcode(rawValue: 11)
        }
    }

    extension Kernel.IO.Uring.Register.Opcode {
        /// Access to restriction registration opcodes.
        public static var restriction: Kernel.IO.Uring.Register.Restriction.Type { Kernel.IO.Uring.Register.Restriction.self }
    }

#endif
