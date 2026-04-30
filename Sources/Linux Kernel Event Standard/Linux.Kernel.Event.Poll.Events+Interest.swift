// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)


    extension ISO_9945.Kernel.Event.Poll.Events {
        /// Project a cross-platform ``Kernel/Descriptor/Interest`` onto the
        /// Linux epoll event mask.
        ///
        /// Maps the request-side readiness categories (`.read`, `.write`,
        /// `.priority`) onto epoll flags, including `.rdhup` with `.read`
        /// to surface peer half-close alongside read readiness (standard
        /// Linux convention for stream sockets).
        ///
        /// ## Policy bits stay at the call site
        ///
        /// This init does NOT set `.et` (edge-triggered) or `.oneshot`.
        /// Those are backend policy and belong where the registration /
        /// submission is built (e.g., the reactor's one-shot helper or the
        /// io_uring `POLL_ADD` submission path — io_uring single-shot is
        /// controlled by the SQE `multishot: false` parameter, not by the
        /// epoll flag).
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Reactor: add edge-triggered + oneshot policy
        /// var events = ISO_9945.Kernel.Event.Poll.Events(interest: interest)
        /// events.insert(.et)
        /// events.insert(.oneshot)
        ///
        /// // io_uring POLL_ADD: just the base mask; multishot=false on SQE
        /// let events = ISO_9945.Kernel.Event.Poll.Events(interest: interest)
        /// entry.poll(target: ..., events: events, multishot: false, ...)
        /// ```
        @inlinable
        public init(interest: ISO_9945.Kernel.Descriptor.Interest) {
            var events: Self = []
            if interest.contains(.read) {
                events.insert(.in)
                events.insert(.rdhup)
            }
            if interest.contains(.write) {
                events.insert(.out)
            }
            if interest.contains(.priority) {
                events.insert(.pri)
            }
            self = events
        }
    }

#endif
