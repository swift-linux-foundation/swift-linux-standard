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
    public import Memory_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension ISO_9945.Kernel.IO.Uring.Completion.Queue {
        /// Byte offsets for completion queue ring mapping.
        ///
        /// Kernel-filled during ``Kernel/IO/Uring/setup(entries:params:)``.
        /// Used by ``Kernel/IO/Uring/init(descriptor:params:)`` to locate
        /// shared-memory fields within the mmap'd CQ ring region.
        public struct Offsets: Sendable, Equatable {
            /// Byte offset to the head counter.
            public let head: Memory.Address.Offset

            /// Byte offset to the tail counter.
            public let tail: Memory.Address.Offset

            /// Byte offset to the ring mask value.
            public let ringMask: Memory.Address.Offset

            /// Byte offset to the ring entries count.
            public let ringEntries: Memory.Address.Offset

            /// Byte offset to the overflow counter.
            public let overflow: Memory.Address.Offset

            /// Byte offset to the CQE array.
            public let cqes: Memory.Address.Offset

            /// Byte offset to the flags field.
            public let flags: Memory.Address.Offset

            internal init() {
                self.head = .zero
                self.tail = .zero
                self.ringMask = .zero
                self.ringEntries = .zero
                self.overflow = .zero
                self.cqes = .zero
                self.flags = .zero
            }

            internal init(_ off: io_cqring_offsets) {
                self.head = Memory.Address.Offset(off.head)
                self.tail = Memory.Address.Offset(off.tail)
                self.ringMask = Memory.Address.Offset(off.ring_mask)
                self.ringEntries = Memory.Address.Offset(off.ring_entries)
                self.overflow = Memory.Address.Offset(off.overflow)
                self.cqes = Memory.Address.Offset(off.cqes)
                self.flags = Memory.Address.Offset(off.flags)
            }
        }
    }

#endif
