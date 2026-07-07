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
    extension ISO_9945.Kernel.IO.Uring.Read {
        /// Vectored read operations.
        public struct Vectored {
            /// Vectored read (readv).
            public static let standard = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 1)

            // TRACKING: Opcode 60 exceeds IORING_OP_LAST=58 in kernel 6.12.
            /// Vectored read into registered buffers (kernel 6.13+).
            public static let fixed = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 60)
        }
    }

#endif
