// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)
    public import Kernel_IO_Primitives

    extension ISO_9945.Kernel.IO.Uring.Register.Files {
        /// File descriptor slot allocation sub-operations.
        public struct Alloc {
            /// Sets the allocation range for file descriptor slots (kernel 6.0+).
            ///
            /// - Linux: `IORING_REGISTER_FILE_ALLOC_RANGE`
            public static let range = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 25)
        }
    }

#endif
