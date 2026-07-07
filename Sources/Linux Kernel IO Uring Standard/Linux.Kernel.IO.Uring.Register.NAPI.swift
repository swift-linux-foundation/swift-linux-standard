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

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {
        /// NAPI (New API) busy-poll registration opcodes.
        ///
        /// Controls Linux networking subsystem busy-polling integration
        /// for reduced latency on network operations.
        public struct NAPI {
            /// Registers NAPI busy-poll settings (kernel 6.9+).
            ///
            /// - Linux: `IORING_REGISTER_NAPI`
            public static let register = Opcode(rawValue: 27)

            /// Unregisters NAPI busy-poll settings.
            ///
            /// - Linux: `IORING_UNREGISTER_NAPI`
            public static let unregister = Opcode(rawValue: 28)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {
        /// Access to NAPI registration opcodes.
        public static var napi: ISO_9945.Kernel.IO.Uring.Register.NAPI.Type { ISO_9945.Kernel.IO.Uring.Register.NAPI.self }
    }

#endif
