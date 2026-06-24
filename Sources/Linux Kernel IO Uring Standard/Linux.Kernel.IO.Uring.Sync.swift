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
        /// Sync operation opcodes.
        public struct Sync {
            /// Access to file sync operations.
            public static var file: File.Type { File.self }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to sync operation opcodes.
        public static var sync: ISO_9945.Kernel.IO.Uring.Sync.Type { ISO_9945.Kernel.IO.Uring.Sync.self }
    }

#endif
