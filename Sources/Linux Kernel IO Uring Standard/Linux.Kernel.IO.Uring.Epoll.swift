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
    public import Kernel_IO_Primitives

    extension Kernel.IO.Uring {
        /// Epoll operation opcodes.
        public struct Epoll {
            /// Add to epoll set.
            public static let ctl = Opcode(rawValue: 29)

            /// Epoll wait (kernel 6.x+).
            public static let wait = Opcode(rawValue: 59)
        }
    }

    extension Kernel.IO.Uring.Opcode {
        /// Access to epoll operation opcodes.
        public static var epoll: Kernel.IO.Uring.Epoll.Type { Kernel.IO.Uring.Epoll.self }
    }

#endif
