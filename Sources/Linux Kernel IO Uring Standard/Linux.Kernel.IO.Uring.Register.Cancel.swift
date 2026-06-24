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
        /// Cancellation registration opcodes.
        public struct Cancel {
            /// Synchronously cancels a pending operation (kernel 6.0+).
            ///
            /// Unlike the `ASYNC_CANCEL` SQE opcode (which is async),
            /// this register operation blocks until the target operation
            /// is cancelled.
            ///
            /// - Linux: `IORING_REGISTER_SYNC_CANCEL`
            public static let synchronous = Opcode(rawValue: 24)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {
        /// Access to cancellation registration opcodes.
        public static var cancel: ISO_9945.Kernel.IO.Uring.Register.Cancel.Type { ISO_9945.Kernel.IO.Uring.Register.Cancel.self }
    }

#endif
