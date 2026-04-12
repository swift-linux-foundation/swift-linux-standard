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
        /// Extended attribute operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by xattr operations:
        /// `IORING_OP_FSETXATTR`, `IORING_OP_SETXATTR`, `IORING_OP_FGETXATTR`,
        /// `IORING_OP_GETXATTR`. Fields: disposition (`rw_flags` as `xattr_flags`),
        /// value pointer (`off` as `addr2`), and path pointer (`addr3`).
        @usableFromInline
        struct Xattr {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Xattr create/replace disposition.
            @usableFromInline
            var disposition: Kernel.IO.Uring.File.Xattr.Disposition {
                get {
                    unsafe Kernel.IO.Uring.File.Xattr.Disposition.createOrReplace // read not meaningful
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.rw_flags = newValue.rawBits)
                }
            }

            /// Set the xattr value pointer.
            ///
            /// Absorbs `UnsafeRawPointer` → `UInt64` conversion internally.
            @usableFromInline
            nonmutating func set(value: UnsafeRawPointer) {
                unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: value)))
            }

            /// Set the xattr value buffer for reading.
            ///
            /// Absorbs `UnsafeMutableRawPointer` → `UInt64` conversion internally.
            @usableFromInline
            nonmutating func set(value: UnsafeMutableRawPointer) {
                unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: value)))
            }

            /// Set the xattr path pointer (for non-f* variants).
            ///
            /// Absorbs `UnsafePointer<CChar>` → `UInt64` conversion internally.
            @usableFromInline
            nonmutating func set(path: UnsafePointer<CChar>) {
                unsafe (pointer.pointee.cValue.addr3 = UInt64(UInt(bitPattern: path)))
            }
        }

        /// Access extended attribute operation fields.
        @inlinable
        var xattr: Xattr { unsafe Xattr(pointer: pointer) }
    }

#endif
