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

    extension ISO_9945.Kernel.IO.Uring.Socket.Transfer {
        /// Flags modifying socket send/receive behavior.
        ///
        /// These flags are stored in the SQE `ioprio` field for
        /// send, recv, sendmsg, recvmsg, send_zc, and sendmsg_zc
        /// operations.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// ring.next.entry.send(
        ///     target: .descriptor(fd),
        ///     buffer: buf,
        ///     length: len,
        ///     flags: [],
        ///     transfer: [.pollFirst],
        ///     data: id
        /// )
        /// ```
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt16

            @inlinable
            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Socket.Transfer.Options {
        /// Try polling for data first before issuing the operation.
        ///
        /// The kernel polls the socket before starting the actual
        /// send/recv. Reduces latency when data is likely available.
        ///
        /// - Linux: `IORING_RECVSEND_POLL_FIRST`
        public static let pollFirst = Self(rawValue: 1 << 0)

        /// Enable multishot receive mode.
        ///
        /// A single SQE produces multiple CQEs as data arrives.
        /// The operation stays active until explicitly cancelled
        /// or a CQE without `IORING_CQE_F_MORE` is posted.
        ///
        /// - Linux: `IORING_RECV_MULTISHOT`
        public static let multishot = Self(rawValue: 1 << 1)

        /// Use a pre-registered fixed buffer.
        ///
        /// The buffer referenced by the SQE is a registered buffer,
        /// avoiding per-operation memory pinning overhead.
        ///
        /// - Linux: `IORING_RECVSEND_FIXED_BUF`
        public static let fixedBuffer = Self(rawValue: 1 << 2)

        /// Report zero-copy usage in the notification CQE.
        ///
        /// When set on a zero-copy send, the notification CQE's
        /// flags indicate whether the data was actually sent
        /// zero-copy or fell back to a copy.
        ///
        /// - Linux: `IORING_SEND_ZC_REPORT_USAGE`
        public static let reportUsage = Self(rawValue: 1 << 3)

        /// Enable bundled send/receive for scatter-gather (kernel 6.10+).
        ///
        /// Multiple buffers are sent or received in a single operation,
        /// reducing per-buffer overhead.
        ///
        /// - Linux: `IORING_RECVSEND_BUNDLE`
        public static let bundle = Self(rawValue: 1 << 4)
    }

#endif
