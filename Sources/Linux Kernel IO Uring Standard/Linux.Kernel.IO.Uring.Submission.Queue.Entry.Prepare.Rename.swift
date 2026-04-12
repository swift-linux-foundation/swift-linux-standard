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
    @_spi(Syscall) public import Kernel_File_Primitives

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif
    public import Linux_Kernel_File_Standard

    // WORKAROUND: Pointer-backed view instead of Property.View — see Splice view.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Rename operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by `IORING_OP_RENAMEAT`:
        /// rename flags (`rw_flags` as `rename_flags`), target directory fd (`len`),
        /// and target path pointer (`off` as `addr2`).
        @usableFromInline
        struct Rename {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Rename flags.
            @usableFromInline
            var flags: Kernel.File.Rename.Options {
                get {
                    unsafe Kernel.File.Rename.Options(rawValue: pointer.pointee.cValue.rw_flags)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.rw_flags = newValue.rawValue)
                }
            }

            /// Set the target directory file descriptor.
            ///
            /// Stored in the `len` field as UInt32(bitPattern: fd).
            @usableFromInline
            nonmutating func set(directory fd: Int32) {
                unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: fd))
            }

            /// Set the target path pointer.
            ///
            /// Absorbs `UnsafePointer<CChar>` → `UInt64` conversion internally.
            /// Stored in the `off` field as `addr2`.
            @usableFromInline
            nonmutating func set(path: UnsafePointer<CChar>) {
                unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: path)))
            }
        }

        /// Access rename operation fields.
        @inlinable
        var rename: Rename { unsafe Rename(pointer: pointer) }
    }

#endif
