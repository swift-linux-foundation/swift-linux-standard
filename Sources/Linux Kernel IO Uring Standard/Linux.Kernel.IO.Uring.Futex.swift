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
        /// Futex operation opcodes (kernel 6.7+).
        public struct Futex {
            /// Futex wait (kernel 6.7+).
            public static let wait = Opcode(rawValue: 51)

            /// Futex wake (kernel 6.7+).
            public static let wake = Opcode(rawValue: 52)

            /// Futex wait v (kernel 6.7+).
            public static let waitv = Opcode(rawValue: 53)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to futex operation opcodes.
        public static var futex: ISO_9945.Kernel.IO.Uring.Futex.Type { ISO_9945.Kernel.IO.Uring.Futex.self }
    }

#endif
