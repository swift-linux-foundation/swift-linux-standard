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

    extension ISO_9945.Kernel.IO.Uring.Send {
        /// Zero-copy send operations.
        public struct Zero {
            /// Send with zero-copy (kernel 6.0+).
            public static let copy = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 47)

            /// Sendmsg with zero-copy (kernel 6.1+).
            public static let msg = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 48)
        }
    }

#endif
