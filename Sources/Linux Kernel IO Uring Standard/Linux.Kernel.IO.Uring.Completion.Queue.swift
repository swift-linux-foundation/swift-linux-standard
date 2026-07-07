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
    extension ISO_9945.Kernel.IO.Uring.Completion {
        /// Namespace for completion queue ring buffer types.
        ///
        /// The completion queue is a ring buffer where the kernel places
        /// results of completed I/O operations (CQEs) for applications to consume.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring/Completion/Queue/Entry``
        /// - ``Kernel/IO/Uring/Completion/Queue/Offsets``
        public enum Queue {}
    }

#endif
