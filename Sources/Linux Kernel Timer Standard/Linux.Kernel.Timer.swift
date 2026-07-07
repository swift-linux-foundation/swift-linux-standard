// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-linux-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel {
        /// Linux kernel timer mechanisms — `timerfd_create(2)` family.
        ///
        /// Distinct from ``ISO_9945/Kernel/Time`` (which models POSIX time
        /// concepts: timespec, clocks). The ``Timer`` namespace contains
        /// kernel timer objects that deliver expirations via file descriptors
        /// — enabling integration with `poll(2)`/`epoll(2)`/`io_uring`.
        public enum Timer: Sendable {}
    }

#endif
