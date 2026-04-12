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
        /// Pipe/splice operation opcodes.
        public struct Pipe {
            /// Splice data between fds.
            public static let splice = Opcode(rawValue: 30)

            /// Transfer data between fds (tee).
            public static let tee = Opcode(rawValue: 33)

            /// Create pipe (kernel 6.x+).
            public static let create = Opcode(rawValue: 62)
        }
    }

    extension Kernel.IO.Uring.Opcode {
        /// Access to pipe/splice operation opcodes.
        public static var pipe: Kernel.IO.Uring.Pipe.Type { Kernel.IO.Uring.Pipe.self }
    }

#endif
