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

public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {
        /// Buffer registration opcodes.
        public struct Buffers {
            /// Registers buffers for zero-copy I/O.
            ///
            /// Pre-pins buffer memory in the kernel, avoiding per-operation
            /// memory registration overhead.
            ///
            /// - Linux: `IORING_REGISTER_BUFFERS`
            public static let register = Opcode(rawValue: 0)

            /// Unregisters previously registered buffers.
            ///
            /// - Linux: `IORING_UNREGISTER_BUFFERS`
            public static let unregister = Opcode(rawValue: 1)

            /// Registers buffers (v2 API, kernel 5.13+).
            ///
            /// Supports sparse registration and resource tagging.
            ///
            /// - Linux: `IORING_REGISTER_BUFFERS2`
            public static let register2 = Opcode(rawValue: 15)

            /// Updates registered buffers (kernel 5.13+).
            ///
            /// - Linux: `IORING_REGISTER_BUFFERS_UPDATE`
            public static let update = Opcode(rawValue: 16)

            /// Clone registered buffers from another ring (kernel 6.12+).
            ///
            /// - Linux: `IORING_REGISTER_CLONE_BUFFERS`
            public static let clone = Opcode(rawValue: 30)

            /// Access to provided buffer ring sub-operations.
            public static var provided: Provided.Type { Provided.self }

            /// Sparse resource registration flag for v2 buffer APIs.
            ///
            /// - Linux: `IORING_REGISTER_SRC_REGISTERED`
            public static let sourceRegistered: UInt32 = 1
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {
        /// Access to buffer registration opcodes.
        public static var buffers: ISO_9945.Kernel.IO.Uring.Register.Buffers.Type { ISO_9945.Kernel.IO.Uring.Register.Buffers.self }
    }

#endif
