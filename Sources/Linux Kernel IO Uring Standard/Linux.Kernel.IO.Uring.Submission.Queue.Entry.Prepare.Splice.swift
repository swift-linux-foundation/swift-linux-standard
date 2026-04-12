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
    @_spi(Syscall) public import Kernel_Descriptor_Primitives
    @_spi(Syscall) public import Kernel_File_Primitives

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif
    public import Linux_Kernel_Pipe_Standard

    // WORKAROUND: Pointer-backed view instead of Property.View.
    // WHY: Entry is Copyable, accessed via UnsafeMutablePointer in the SQE ring buffer.
    //   Property.View requires ~Copyable base with _read/_modify coroutines.
    //   This view uses nonmutating set through the pointer — [IMPL-071] pattern.
    // WHEN TO REMOVE: When Property gains a pointer-backed variant for Copyable bases.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Splice/tee operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by `IORING_OP_SPLICE`
        /// and `IORING_OP_TEE`: the source descriptor (`splice_fd_in`) and
        /// operation flags (`rw_flags` as `splice_flags`).
        @usableFromInline
        struct Splice {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Set the splice source descriptor.
            ///
            /// Absorbs `Kernel.Descriptor._rawValue` extraction internally.
            @usableFromInline
            nonmutating func set(source: borrowing Kernel.Descriptor) {
                unsafe (pointer.pointee.cValue.splice_fd_in = source._rawValue)
            }

            /// Splice/tee operation flags.
            @usableFromInline
            var flags: Kernel.Pipe.Splice.Options {
                get {
                    unsafe Kernel.Pipe.Splice.Options(rawValue: pointer.pointee.cValue.rw_flags)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.rw_flags = newValue.rawValue)
                }
            }
        }

        /// Access splice/tee operation fields.
        @inlinable
        var splice: Splice { unsafe Splice(pointer: pointer) }
    }

#endif
