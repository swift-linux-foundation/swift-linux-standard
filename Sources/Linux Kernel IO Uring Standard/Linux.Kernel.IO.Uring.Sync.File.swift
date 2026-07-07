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
    extension ISO_9945.Kernel.IO.Uring.Sync {
        /// File sync operations.
        public struct File {
            /// File sync (fsync).
            public static let standard = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 3)

            /// Sync file data range.
            public static let range = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 8)
        }
    }

#endif
