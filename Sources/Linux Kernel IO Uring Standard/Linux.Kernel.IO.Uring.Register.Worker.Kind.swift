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
    extension ISO_9945.Kernel.IO.Uring.Register.Worker {
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

#endif
