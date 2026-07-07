// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {
        /// Namespace for io_uring_register related types.
        ///
        /// Contains opcodes and types for registering resources with io_uring.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring/Register/Opcode``
        public enum Register {}
    }

#endif
