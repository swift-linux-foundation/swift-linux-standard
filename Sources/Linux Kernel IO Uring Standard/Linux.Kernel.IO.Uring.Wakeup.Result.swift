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
    @_spi(Syscall) public import Linux_Kernel_Event_Standard

    extension ISO_9945.Kernel.IO.Uring.Wakeup {
        /// Bundle returned by ``Kernel/IO/Uring/createWakeup()``.
        ///
        /// ~Copyable because it contains a ~Copyable ``Kernel/Event/Descriptor``.
        /// Access `channel` directly; extract `eventfd` via consuming call.
        public struct Result: ~Copyable {
            /// The wakeup channel — signals completions via eventfd.
            /// Sendable, safe to capture in cross-thread closures.
            public let channel: ISO_9945.Kernel.Wakeup.Channel

            private var _eventfd: ISO_9945.Kernel.Event.Descriptor?

            init(
                channel: ISO_9945.Kernel.Wakeup.Channel,
                eventfd: consuming ISO_9945.Kernel.Event.Descriptor
            ) {
                self.channel = channel
                self._eventfd = consume eventfd
            }

            /// Extract the eventfd descriptor, consuming this result.
            ///
            /// The caller takes ownership of the eventfd — its deinit closes the fd.
            public consuming func eventfd() -> ISO_9945.Kernel.Event.Descriptor {
                _eventfd.take()!
            }
        }
    }

#endif
