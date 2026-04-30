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
        /// Fixed fd operation opcodes.
        public struct Fixed {
            /// Install fixed fd into process table (kernel 6.7+).
            public static let install = Opcode(rawValue: 54)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to fixed fd operation opcodes.
        public static var fixed: ISO_9945.Kernel.IO.Uring.Fixed.Type { ISO_9945.Kernel.IO.Uring.Fixed.self }
    }

#endif
