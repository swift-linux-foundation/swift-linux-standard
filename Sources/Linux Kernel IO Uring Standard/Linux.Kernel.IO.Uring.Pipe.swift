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
    extension ISO_9945.Kernel.IO.Uring {
        /// Pipe/splice operation opcodes.
        public struct Pipe {
            /// Splice data between fds.
            public static let splice = Opcode(rawValue: 30)

            /// Transfer data between fds (tee).
            public static let tee = Opcode(rawValue: 33)

            /// Create pipe (kernel 6.13+).
            // TRACKING: Opcode 62 exceeds IORING_OP_LAST=58 in kernel 6.12.
            public static let create = Opcode(rawValue: 62)

            /// Use a fixed (registered) file descriptor as the splice source.
            ///
            /// OR this with the `splice_fd_in` SQE field value to indicate
            /// the source fd is a fixed file index.
            ///
            /// - Linux: `SPLICE_F_FD_IN_FIXED`
            public static let fixedDescriptorIn: UInt32 = 0x8000_0000
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to pipe/splice operation opcodes.
        public static var pipe: ISO_9945.Kernel.IO.Uring.Pipe.Type { ISO_9945.Kernel.IO.Uring.Pipe.self }
    }

#endif
