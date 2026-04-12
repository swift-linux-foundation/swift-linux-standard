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
    extension Kernel.IO.Uring.Read {
        /// Vectored read operations.
        public struct Vectored {
            /// Vectored read (readv).
            public static let standard = Kernel.IO.Uring.Opcode(rawValue: 1)

            /// Vectored read into registered buffers (kernel 6.x+).
            public static let fixed = Kernel.IO.Uring.Opcode(rawValue: 60)
        }
    }

#endif
