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

public import Kernel_Primitives_Core

extension Kernel.Futex.Wait {
    /// A single entry in a vectored futex wait operation.
    ///
    /// Layout-compatible with `struct futex_waitv` from `<linux/futex.h>`.
    /// An `UnsafePointer<Entry>` to a contiguous array may be passed
    /// directly to kernel interfaces that expect `struct futex_waitv *`.
    public struct Entry: Sendable, Equatable, Hashable {
        /// Expected value to compare against the futex word.
        public var value: UInt64

        /// Address of the futex word (as a kernel `__u64` address).
        public var address: UInt64

        /// Futex flags for this entry.
        public var flags: UInt32

        /// Reserved field — must be zero.
        internal var _reserved: UInt32

        /// Creates a futex wait vector entry.
        ///
        /// - Parameters:
        ///   - value: Expected value to compare against.
        ///   - address: Address of the futex word.
        ///   - flags: Futex flags for this entry.
        public init(value: UInt64, address: UInt64, flags: UInt32) {
            self.value = value
            self.address = address
            self.flags = flags
            self._reserved = 0
        }
    }
}

#endif
