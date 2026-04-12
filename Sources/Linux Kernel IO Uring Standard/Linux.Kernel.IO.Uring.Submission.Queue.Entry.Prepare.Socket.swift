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
    public import Kernel_Socket_Primitives

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif
    public import Linux_Kernel_Socket_Standard

    // WORKAROUND: Pointer-backed view instead of Property.View — see Splice view.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Socket creation operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by `IORING_OP_SOCKET`:
        /// address family (`fd`), socket kind (`off`), protocol (`len`),
        /// and socket flags (`rw_flags`).
        @usableFromInline
        struct Socket {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Socket address family.
            @usableFromInline
            var domain: Kernel.Socket.Address.Family {
                get {
                    unsafe Kernel.Socket.Address.Family(rawValue: pointer.pointee.cValue.fd)
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.fd = newValue.rawValue)
                }
            }

            /// Socket kind (stream, datagram, etc.).
            @usableFromInline
            var kind: Kernel.Socket.Kind {
                get {
                    unsafe Kernel.Socket.Kind(rawValue: Int32(truncatingIfNeeded: pointer.pointee.cValue.off))
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.off = UInt64(UInt32(bitPattern: newValue.rawValue)))
                }
            }

            /// Network protocol.
            @usableFromInline
            var `protocol`: Kernel.Socket.`Protocol` {
                get {
                    unsafe .init(rawValue: Int32(bitPattern: pointer.pointee.cValue.len))
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: newValue.rawValue))
                }
            }

            /// Socket creation flags.
            @usableFromInline
            var flags: Kernel.Socket.Options {
                get {
                    unsafe Kernel.Socket.Options(rawValue: Int32(bitPattern: pointer.pointee.cValue.rw_flags))
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.rw_flags = UInt32(bitPattern: newValue.rawValue))
                }
            }
        }

        /// Access socket creation operation fields.
        @inlinable
        var socket: Socket { unsafe Socket(pointer: pointer) }
    }

#endif
