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

    extension ISO_9945.Kernel.IO.Uring {
        /// Namespace for submission queue types.
        ///
        /// Contains types for the submission queue (SQ) side of io_uring,
        /// including queue entries, entry flags, and ring buffer offsets.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring/Submission/Queue``
        /// - ``Kernel/IO/Uring/Submission/Queue/Entry``
        /// - ``Kernel/IO/Uring/Completion``
        public enum Submission {}
    }

    extension ISO_9945.Kernel.IO.Uring.Submission {
        /// Number of submission queue entries.
        ///
        /// Used for ring setup (how many SQEs to allocate), submission
        /// batching (how many to submit per enter call), and tracking
        /// pending submissions.
        public typealias Count = Tagged<ISO_9945.Kernel.IO.Uring.Submission, Cardinal>
    }

#endif
