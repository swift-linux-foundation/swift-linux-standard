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
        /// Read operation opcodes.
        public struct Read {
            /// Read from file (pread-like, kernel 5.6+).
            public static let standard = Opcode(rawValue: 22)

            /// Access to vectored read operations.
            public static var vectored: Vectored.Type { Vectored.self }

            /// Read from fixed buffers (readv with registered buffers).
            public static let fixed = Opcode(rawValue: 4)

            /// Read multishot (kernel 6.2+).
            public static let multishot = Opcode(rawValue: 49)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to read operation opcodes.
        public static var read: ISO_9945.Kernel.IO.Uring.Read.Type { ISO_9945.Kernel.IO.Uring.Read.self }
    }

#endif
