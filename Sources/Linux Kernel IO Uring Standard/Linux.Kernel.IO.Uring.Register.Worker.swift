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
            /// Worker CPU affinity sub-operations.
            public struct Affinity {
                /// Sets CPU affinity for io-wq workers (kernel 5.14+).
                ///
                /// - Linux: `IORING_REGISTER_IOWQ_AFF`
                public static let register = Opcode(rawValue: 17)

                /// Removes CPU affinity for io-wq workers.
                ///
                /// - Linux: `IORING_UNREGISTER_IOWQ_AFF`
                public static let unregister = Opcode(rawValue: 18)
            }

            /// Access to worker affinity sub-operations.
            public static var affinity: Affinity.Type { Affinity.self }

            /// Sets maximum io-wq worker count (kernel 5.15+).
            ///
            /// - Linux: `IORING_REGISTER_IOWQ_MAX_WORKERS`
            public static let max = Opcode(rawValue: 19)

            /// Worker pool types.
            public enum Kind: UInt32, Sendable {
                /// Bound workers — pinned to the submitting task.
                ///
                /// - Linux: `IO_WQ_BOUND`
                case bound = 0

                /// Unbound workers — shared across tasks.
                ///
                /// - Linux: `IO_WQ_UNBOUND`
                case unbound = 1
            }
        }
    }

    extension Kernel.IO.Uring.Register.Opcode {
        /// Access to worker pool management opcodes.
        public static var worker: Kernel.IO.Uring.Register.Worker.Type { Kernel.IO.Uring.Register.Worker.self }
    }

#endif
