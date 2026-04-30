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

    extension ISO_9945.Kernel.IO.Uring.Register.Worker {
        /// Worker CPU affinity sub-operations.
        public struct Affinity {
            /// Sets CPU affinity for io-wq workers (kernel 5.14+).
            ///
            /// - Linux: `IORING_REGISTER_IOWQ_AFF`
            public static let register = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 17)

            /// Removes CPU affinity for io-wq workers.
            ///
            /// - Linux: `IORING_UNREGISTER_IOWQ_AFF`
            public static let unregister = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 18)
        }
    }

#endif
