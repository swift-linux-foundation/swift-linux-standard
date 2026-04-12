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
    extension Kernel.IO.Uring.Write {
        /// Vectored write operations.
        public struct Vectored {
            /// Vectored write (writev).
            public static let standard = Kernel.IO.Uring.Opcode(rawValue: 2)

            /// Vectored write from registered buffers (kernel 6.13+).
            // TRACKING: Opcode 61 exceeds IORING_OP_LAST=58 in kernel 6.12.
            public static let fixed = Kernel.IO.Uring.Opcode(rawValue: 61)
        }
    }

#endif
