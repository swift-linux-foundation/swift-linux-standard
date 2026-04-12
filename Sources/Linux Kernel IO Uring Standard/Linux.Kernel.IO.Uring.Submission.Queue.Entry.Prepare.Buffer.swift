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
        /// Buffer management operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by buffer operations:
        /// `IORING_OP_PROVIDE_BUFFERS`, `IORING_OP_REMOVE_BUFFERS`, and the
        /// `buf_index`/`buf_group` fields for fixed and multishot reads.
        @usableFromInline
        struct Buffer {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Registered buffer index.
            @usableFromInline
            var index: Kernel.IO.Uring.Buffer.Index {
                get {
                    unsafe Kernel.IO.Uring.Buffer.Index(rawValue: pointer.pointee.cValue.buf_index)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.buf_index = newValue.rawValue)
                }
            }

            /// Buffer group for kernel-selected buffers.
            @usableFromInline
            var group: Kernel.IO.Uring.Buffer.Group {
                get {
                    unsafe Kernel.IO.Uring.Buffer.Group(rawValue: pointer.pointee.cValue.buf_group)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.buf_group = newValue.rawValue)
                }
            }

            /// Number of buffers to provide or remove (stored in fd field).
            @usableFromInline
            var count: Int32 {
                get {
                    unsafe pointer.pointee.cValue.fd
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.fd = newValue)
                }
            }

            /// Starting buffer ID (stored in off field).
            @usableFromInline
            var startID: UInt16 {
                get {
                    unsafe UInt16(truncatingIfNeeded: pointer.pointee.cValue.off)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.off = UInt64(newValue))
                }
            }
        }

        /// Access buffer management operation fields.
        @inlinable
        var buffer: Buffer { unsafe Buffer(pointer: pointer) }
    }

#endif
