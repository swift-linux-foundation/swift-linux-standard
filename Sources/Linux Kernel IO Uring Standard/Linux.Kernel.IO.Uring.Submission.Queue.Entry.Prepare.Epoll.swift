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
    @_spi(Syscall) public import Kernel_Descriptor_Primitives
    public import Kernel_Event_Primitives
    public import Linux_Kernel_Event_Standard

    // WORKAROUND: Pointer-backed view instead of Property.View — see Splice view.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Epoll operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by epoll operations:
        /// `IORING_OP_EPOLL_CTL` and `IORING_OP_EPOLL_WAIT`.
        ///
        /// - `operation` and `set(descriptor:)` are for epoll_ctl.
        /// - `maxEvents` is for epoll_wait.
        @usableFromInline
        struct Epoll {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Epoll control operation (add, modify, delete).
            ///
            /// For `epoll_ctl` — stored in the `len` field.
            @usableFromInline
            var operation: Kernel.Event.Poll.Operation {
                get {
                    unsafe Kernel.Event.Poll.Operation(rawValue: Int32(bitPattern: pointer.pointee.cValue.len))
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: newValue.rawValue))
                }
            }

            /// Maximum events to return.
            ///
            /// For `epoll_wait` — stored in the `len` field.
            @usableFromInline
            var maxEvents: Int32 {
                get {
                    unsafe Int32(bitPattern: pointer.pointee.cValue.len)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: newValue))
                }
            }

            /// Set the target file descriptor for epoll_ctl.
            ///
            /// Absorbs `Kernel.Descriptor._rawValue` extraction internally.
            /// Stored in the `off` field.
            @usableFromInline
            nonmutating func set(descriptor: borrowing Kernel.Descriptor) {
                unsafe (pointer.pointee.cValue.off = UInt64(UInt32(bitPattern: descriptor._rawValue)))
            }
        }

        /// Access epoll operation fields.
        @inlinable
        var epoll: Epoll { unsafe Epoll(pointer: pointer) }
    }

#endif
