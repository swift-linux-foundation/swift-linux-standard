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

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue {
        /// Runtime flags on the SQ ring shared-memory flags field.
        ///
        /// These flags are set by the kernel and read by userspace from
        /// the mmap'd `flags` field at `Submission.Queue.Offsets.flags`.
        ///
        /// Distinct from ``Entry/Options`` which are per-SQE flags
        /// (`IOSQE_*`) set by the application.
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Options {
        /// The kernel SQ poll thread needs a wakeup.
        ///
        /// When set, the application must call `io_uring_enter` with
        /// `.sqWakeup` to restart the kernel polling thread. Only
        /// relevant when `.sqPoll` setup flag is used.
        ///
        /// - Linux: `IORING_SQ_NEED_WAKEUP`
        public static let needWakeup = Self(rawValue: 1 << 0)

        /// The completion queue has overflowed.
        ///
        /// The kernel could not post a CQE because the CQ ring was
        /// full. Userspace should drain completions promptly.
        ///
        /// - Linux: `IORING_SQ_CQ_OVERFLOW`
        public static let completionOverflow = Self(rawValue: 1 << 1)

        /// Pending task work is available.
        ///
        /// Set when `.taskrunFlag` setup flag is used. Indicates the
        /// application should call `io_uring_enter` to process
        /// deferred task work.
        ///
        /// - Linux: `IORING_SQ_TASKRUN`
        public static let taskrun = Self(rawValue: 1 << 2)
    }

#endif
