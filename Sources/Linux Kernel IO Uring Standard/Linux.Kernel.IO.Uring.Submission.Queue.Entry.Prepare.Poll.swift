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
    @_spi(Syscall) public import Kernel_IO_Primitives
    public import Kernel_Event_Primitives

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif
    public import Linux_Kernel_Event_Standard

    // WORKAROUND: Pointer-backed view instead of Property.View — see Splice view.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Poll operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by `IORING_OP_POLL_ADD`:
        /// the poll event mask (`poll32_events`) and poll options (`len` as
        /// trigger mode + multishot flags).
        @usableFromInline
        struct Poll {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Poll event mask (e.g., `.in`, `.out`).
            @usableFromInline
            var events: Kernel.Event.Poll.Events {
                get {
                    unsafe Kernel.Event.Poll.Events(rawValue: pointer.pointee.cValue.poll32_events)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.poll32_events = newValue.rawValue)
                }
            }

            /// Poll options (trigger mode + multishot).
            ///
            /// Stored in the `len` field — not the usual byte-length semantic.
            @usableFromInline
            var options: Kernel.IO.Uring.Poll.Options {
                get {
                    unsafe Kernel.IO.Uring.Poll.Options(rawValue: pointer.pointee.cValue.len)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.len = newValue.rawValue)
                }
            }
        }

        /// Access poll operation fields.
        @inlinable
        var poll: Poll { unsafe Poll(pointer: pointer) }
    }

#endif
