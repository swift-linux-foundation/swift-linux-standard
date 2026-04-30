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

    extension ISO_9945.Kernel.IO.Uring.Accept {
        /// Flags controlling accept operation behavior.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Multishot accept — single SQE accepts many connections
        /// ring.next.entry.accept(
        ///     target: .descriptor(listenFd),
        ///     options: [.multishot],
        ///     data: id
        /// )
        /// ```
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Accept.Options {
        /// Accept multiple connections from a single SQE (kernel 5.19+).
        ///
        /// Each accepted connection produces a CQE with `IORING_CQE_F_MORE`.
        /// The accept remains active until cancelled or a CQE without
        /// `.more` is posted.
        ///
        /// - Linux: `IORING_ACCEPT_MULTISHOT`
        public static let multishot = Self(rawValue: 1 << 0)

        /// Non-blocking accept — return immediately if no pending connections.
        ///
        /// - Linux: `IORING_ACCEPT_DONTWAIT`
        public static let dontWait = Self(rawValue: 1 << 1)

        /// Try polling for a pending connection before issuing accept.
        ///
        /// - Linux: `IORING_ACCEPT_POLL_FIRST`
        public static let pollFirst = Self(rawValue: 1 << 2)
    }

#endif
