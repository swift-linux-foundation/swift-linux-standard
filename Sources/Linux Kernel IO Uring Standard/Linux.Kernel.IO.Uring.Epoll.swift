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

    extension ISO_9945.Kernel.IO.Uring {
        /// Epoll operation opcodes.
        public struct Epoll {
            /// Add to epoll set.
            public static let ctl = Opcode(rawValue: 29)

            /// Epoll wait (kernel 6.13+).
            // TRACKING: Opcode 59 exceeds IORING_OP_LAST=58 in kernel 6.12.
            public static let wait = Opcode(rawValue: 59)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to epoll operation opcodes.
        public static var epoll: ISO_9945.Kernel.IO.Uring.Epoll.Type { ISO_9945.Kernel.IO.Uring.Epoll.self }
    }

#endif
