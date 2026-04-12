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

    extension Kernel.IO.Uring {
        /// Sync operation opcodes.
        public struct Sync {
            /// Access to file sync operations.
            public static var file: File.Type { File.self }
        }
    }

    extension Kernel.IO.Uring.Opcode {
        /// Access to sync operation opcodes.
        public static var sync: Kernel.IO.Uring.Sync.Type { Kernel.IO.Uring.Sync.self }
    }

#endif
