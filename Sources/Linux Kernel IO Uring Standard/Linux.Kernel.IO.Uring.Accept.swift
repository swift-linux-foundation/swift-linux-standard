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

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {
        /// Accept operation modifiers.
        ///
        /// Namespace for flags specific to the accept opcode
        /// (`IORING_OP_ACCEPT`). Parallels `Cancel`, `Poll`, `Timeout`.
        public enum Accept {}
    }

#endif
