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

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension ISO_9945.Kernel.IO.Uring {
        /// Clock source for io_uring timeout operations.
        ///
        /// Determines which kernel clock is used to interpret timeout values.
        /// The default is `.monotonic` — a clock that never goes backward and
        /// is unaffected by NTP adjustments, but does NOT advance during system
        /// suspend.
        ///
        /// ## Clock Behavior
        ///
        /// | Clock | Advances during suspend? | Affected by NTP? | Use when |
        /// |-------|-------------------------|------------------|----------|
        /// | `.monotonic` | No | No | Default — most operations |
        /// | `.boottime` | Yes | No | Need to include suspend time |
        /// | `.realtime` | Yes | Yes | Need wall-clock time |
        public enum Clock: Sendable, Hashable {
            /// CLOCK_MONOTONIC — does not advance during suspend.
            case monotonic

            /// CLOCK_BOOTTIME — includes time spent in suspend.
            case boottime

            /// CLOCK_REALTIME — wall clock, affected by NTP adjustments.
            case realtime
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Clock {
        /// The io_uring timeout flag bits for this clock source.
        @usableFromInline
        var timeoutBits: UInt32 {
            switch self {
            case .monotonic: 0
            case .boottime: UInt32(IORING_TIMEOUT_BOOTTIME)
            case .realtime: UInt32(IORING_TIMEOUT_REALTIME)
            }
        }
    }

#endif
