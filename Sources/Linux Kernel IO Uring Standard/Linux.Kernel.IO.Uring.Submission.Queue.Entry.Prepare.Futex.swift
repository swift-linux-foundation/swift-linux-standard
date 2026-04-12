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
    @_spi(Syscall) public import Kernel_IO_Primitives
    public import Linux_Kernel_Futex_Standard

    // WORKAROUND: Pointer-backed view instead of Property.View — see Splice view.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Futex operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by futex operations:
        /// `IORING_OP_FUTEX_WAIT`, `IORING_OP_FUTEX_WAKE`, and
        /// `IORING_OP_FUTEX_WAITV`. Fields: flags (`rw_flags`),
        /// comparison mask (`addr3`), and entry count (`len`).
        @usableFromInline
        struct Futex {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Futex operation flags.
            @usableFromInline
            var flags: Kernel.Futex.Options {
                get {
                    unsafe Kernel.Futex.Options(rawValue: pointer.pointee.cValue.rw_flags)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.rw_flags = newValue.rawValue)
                }
            }

            /// Futex comparison mask.
            @usableFromInline
            var mask: UInt64 {
                get {
                    unsafe pointer.pointee.cValue.addr3
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.addr3 = newValue)
                }
            }

            /// Entry count for vectored futex operations (futex_waitv).
            @usableFromInline
            var count: UInt32 {
                get {
                    unsafe pointer.pointee.cValue.len
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.len = newValue)
                }
            }
        }

        /// Access futex operation fields.
        @inlinable
        var futex: Futex { unsafe Futex(pointer: pointer) }
    }

#endif
