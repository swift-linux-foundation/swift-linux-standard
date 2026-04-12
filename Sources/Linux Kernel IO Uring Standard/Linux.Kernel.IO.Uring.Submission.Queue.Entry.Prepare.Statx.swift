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
    @_spi(Syscall) public import Kernel_File_Primitives
    public import Linux_Kernel_File_Standard
    public import ISO_9945_Kernel_File

    // WORKAROUND: Pointer-backed view instead of Property.View — see Splice view.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Statx operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by `IORING_OP_STATX`:
        /// AT_* flags (`rw_flags` as `statx_flags`), field mask (`len`),
        /// and result buffer pointer (`off` as `addr2`).
        @usableFromInline
        struct Statx {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Statx AT_* flags (e.g., `AT_SYMLINK_NOFOLLOW`).
            @usableFromInline
            var flags: Kernel.File.At.Options {
                get {
                    unsafe Kernel.File.At.Options(rawValue: Int32(bitPattern: pointer.pointee.cValue.rw_flags))
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.rw_flags = UInt32(bitPattern: newValue.rawValue))
                }
            }

            /// Statx field mask (which fields to populate).
            @usableFromInline
            var mask: Kernel.File.Statx.Mask {
                get {
                    unsafe Kernel.File.Statx.Mask(rawValue: pointer.pointee.cValue.len)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.len = newValue.rawValue)
                }
            }

            /// Set the statx result buffer pointer.
            ///
            /// Absorbs `UnsafeMutablePointer` → `UInt64` conversion internally.
            @usableFromInline
            nonmutating func set(buffer: UnsafeMutablePointer<Kernel.File.Statx>) {
                unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: buffer)))
            }
        }

        /// Access statx operation fields.
        @inlinable
        var statx: Statx { unsafe Statx(pointer: pointer) }
    }

#endif
