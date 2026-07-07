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
    extension ISO_9945.Kernel.IO.Uring.Completion.Queue {
        /// Runtime flags on the CQ ring shared-memory flags field.
        ///
        /// These flags are read from the mmap'd `flags` field at
        /// `Completion.Queue.Offsets.flags`. Both the kernel and
        /// userspace may read/write these.
        ///
        /// Distinct from ``Entry/Options`` which are per-CQE flags
        /// (`IORING_CQE_F_*`) set by the kernel on each completion.
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Completion.Queue.Options {
        /// Disable eventfd notifications.
        ///
        /// When set, completions do not signal the registered eventfd.
        ///
        /// Userspace can toggle this flag to temporarily suppress
        /// notifications.
        ///
        /// - Linux: `IORING_CQ_EVENTFD_DISABLED`
        public static let eventDescriptorDisabled = Self(rawValue: 1 << 0)
    }

#endif
