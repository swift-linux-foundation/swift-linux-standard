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

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif
    public import Kernel_Process_Primitives
    public import Linux_Kernel_System_Standard
    public import ISO_9945_Core

    // WORKAROUND: Pointer-backed view instead of Property.View — see Splice view.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Waitid operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by `IORING_OP_WAITID`:
        /// process ID (`fd`), wait kind (`len`), signal info pointer (`off` as
        /// `addr2`), POSIX wait options (`file_index`), and io_uring wait flags
        /// (`rw_flags` as `waitid_flags`).
        @usableFromInline
        struct Waitid {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Set the target process ID.
            ///
            /// Absorbs `Kernel.Process.ID.rawValue` extraction internally.
            @usableFromInline
            nonmutating func set(process id: Kernel.Process.ID) {
                unsafe (pointer.pointee.cValue.fd = id.rawValue)
            }

            /// Wait kind — which type of process identifier to wait for.
            @usableFromInline
            var kind: Kernel.Process.Wait.Kind {
                get {
                    unsafe Kernel.Process.Wait.Kind(rawValue: Int32(bitPattern: pointer.pointee.cValue.len))
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: newValue.rawValue))
                }
            }

            /// Set the signal information buffer pointer.
            ///
            /// Absorbs pointer → UInt64 conversion internally.
            @usableFromInline
            nonmutating func set(info: UnsafeMutablePointer<Kernel.Signal.Information>) {
                unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: info)))
            }

            /// POSIX wait options (W_EXITED, W_STOPPED, etc.).
            ///
            /// Stored in the `file_index` SQE field.
            @usableFromInline
            var waitOptions: Kernel.Process.Wait.Options {
                get {
                    unsafe Kernel.Process.Wait.Options(rawValue: Int32(bitPattern: pointer.pointee.cValue.file_index))
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.file_index = UInt32(bitPattern: newValue.rawValue))
                }
            }

            /// io_uring-level wait flags.
            ///
            /// Stored in the `rw_flags` SQE field.
            @usableFromInline
            var uringFlags: Kernel.IO.Uring.Wait.Options {
                get {
                    unsafe Kernel.IO.Uring.Wait.Options(rawValue: pointer.pointee.cValue.rw_flags)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.rw_flags = newValue.rawValue)
                }
            }
        }

        /// Access waitid operation fields.
        @inlinable
        var waitid: Waitid { unsafe Waitid(pointer: pointer) }
    }

#endif
