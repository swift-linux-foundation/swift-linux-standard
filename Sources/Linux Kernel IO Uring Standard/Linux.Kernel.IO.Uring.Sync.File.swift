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
    extension Kernel.IO.Uring.Sync {
        /// File sync operations.
        public struct File {
            /// File sync (fsync).
            public static let standard = Kernel.IO.Uring.Opcode(rawValue: 3)

            /// Sync file data range.
            public static let range = Kernel.IO.Uring.Opcode(rawValue: 8)
        }
    }

#endif
