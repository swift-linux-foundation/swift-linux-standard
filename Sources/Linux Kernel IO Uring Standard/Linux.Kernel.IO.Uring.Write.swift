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
        /// Write operation opcodes.
        public struct Write {
            /// Write to file (pwrite-like, kernel 5.6+).
            public static let standard = Opcode(rawValue: 23)

            /// Access to vectored write operations.
            public static var vectored: Vectored.Type { Vectored.self }

            /// Write to fixed buffers (writev with registered buffers).
            public static let fixed = Opcode(rawValue: 5)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to write operation opcodes.
        public static var write: ISO_9945.Kernel.IO.Uring.Write.Type { ISO_9945.Kernel.IO.Uring.Write.self }
    }

#endif
