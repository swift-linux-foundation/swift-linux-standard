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
        /// I/O worker pool management opcodes.
        ///
        /// Controls the io-wq worker threads that execute async
        /// io_uring operations.
        public struct Worker {
            /// Access to worker affinity sub-operations.
            public static var affinity: Affinity.Type { Affinity.self }

            /// Sets maximum io-wq worker count (kernel 5.15+).
            ///
            /// - Linux: `IORING_REGISTER_IOWQ_MAX_WORKERS`
            public static let max = Opcode(rawValue: 19)
        }
    }

    extension Kernel.IO.Uring.Register.Opcode {
        /// Access to worker pool management opcodes.
        public static var worker: Kernel.IO.Uring.Register.Worker.Type { Kernel.IO.Uring.Register.Worker.self }
    }

#endif
