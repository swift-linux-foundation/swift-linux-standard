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

    // WORKAROUND: Pointer-backed view instead of Property.View — see Splice view.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Ring-to-ring message operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by `IORING_OP_MSG_RING`:
        /// target ring fd (`fd`), CQE result value (`len`), target user_data (`off`),
        /// and message flags (`rw_flags` as `msg_ring_flags`).
        @usableFromInline
        struct Message {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Target ring file descriptor.
            @usableFromInline
            var ring: Int32 {
                get {
                    unsafe pointer.pointee.cValue.fd
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.fd = newValue)
                }
            }

            /// Value to inject as the CQE `res` field.
            @usableFromInline
            var value: UInt32 {
                get {
                    unsafe pointer.pointee.cValue.len
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.len = newValue)
                }
            }

            /// User data for the injected CQE.
            @usableFromInline
            var target: UInt64 {
                get {
                    unsafe pointer.pointee.cValue.off
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.off = newValue)
                }
            }

            /// Message ring flags.
            @usableFromInline
            var flags: Kernel.IO.Uring.Message.Options {
                get {
                    unsafe Kernel.IO.Uring.Message.Options(rawValue: pointer.pointee.cValue.rw_flags)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.rw_flags = newValue.rawValue)
                }
            }
        }

        /// Access ring-to-ring message operation fields.
        @inlinable
        var message: Message { unsafe Message(pointer: pointer) }
    }

#endif
