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
    extension ISO_9945.Kernel.IO.Uring.Submission.Queue {
        /// Ring mask — extracts physical slot from a monotonic UInt32 counter.
        ///
        /// Invariant: `rawValue == entries - 1` (always one less than power-of-2).
        /// This mirrors the kernel's `ring_mask` field in shared memory.
        public struct Mask: Sendable, Equatable {
            @usableFromInline
            let rawValue: UInt32

            @inlinable
            init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Physical slot index for a counter value.
            @inlinable
            public func slot(for counter: UInt32) -> Int {
                Int(counter & rawValue)
            }
        }
    }

#endif
