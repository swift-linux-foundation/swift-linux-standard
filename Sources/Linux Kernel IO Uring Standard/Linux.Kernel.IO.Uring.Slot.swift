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
    extension ISO_9945.Kernel.IO.Uring {
        /// A slot in the submission queue ring buffer.
        ///
        /// `~Copyable` prevents aliasing the underlying mmap'd SQE.
        /// `~Escapable` confines the slot to the coroutine scope that yielded it —
        /// the `_read` scope on ``Kernel/IO/Uring/next`` IS the lifetime boundary.
        ///
        /// Access the SQE through ``entry``:
        /// ```swift
        /// ring.next.entry.read(target: .descriptor(fd), buffer: buf, length: len, offset: .zero, data: id)
        /// ring.next.entry.flags.insert(.link)  // same slot — tail unchanged
        /// ring.advance()
        /// ```
        @safe public struct Slot: ~Copyable, ~Escapable {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Submission.Queue.Entry>

            @lifetime(borrow pointer)
            @usableFromInline @unsafe
            init(_ pointer: UnsafeMutablePointer<Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// The submission queue entry at this slot.
            ///
            /// `_read` yields a copy for inspection.
            /// `nonmutating _modify` yields an `inout` reference that writes
            /// through the stored pointer directly into mmap'd shared memory —
            /// zero copies, no write-back.
            @inlinable
            public var entry: Submission.Queue.Entry {
                _read { yield unsafe pointer.pointee }
                nonmutating _modify { yield unsafe &pointer.pointee }
            }
        }
    }

#endif
