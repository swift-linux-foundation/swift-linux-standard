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

@_spi(Syscall) public import ISO_9945_Core
    @_spi(Syscall) public import Linux_Kernel_Event_Standard

    extension ISO_9945.Kernel.IO.Uring.Wakeup {
        /// Bundle returned by ``Kernel/IO/Uring/createWakeup()``.
        ///
        /// ~Copyable because it contains a ~Copyable ``Kernel/Event/Descriptor``.
        /// Access `signal` directly; extract `eventfd` via consuming call.
        public struct Result: ~Copyable {
            /// The signal closure — signals completions via eventfd.
            /// `@Sendable`, safe to capture in cross-thread closures.
            ///
            /// L3 consumers wrap into `Kernel.Wakeup.Channel(signal:)` at the
            /// site of use; the closure carries the raw fd capture so L3 callers
            /// never see `_rawValue` (typed-everywhere discipline per [PLAT-ARCH-008j]).
            public let signal: @Sendable () -> Void

            private var _eventfd: ISO_9945.Kernel.Event.Descriptor?

            init(
                signal: @escaping @Sendable () -> Void,
                eventfd: consuming ISO_9945.Kernel.Event.Descriptor
            ) {
                self.signal = signal
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
