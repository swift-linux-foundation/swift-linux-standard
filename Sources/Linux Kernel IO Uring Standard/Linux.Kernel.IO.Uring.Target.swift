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

    extension Kernel.IO.Uring {
        /// How an io_uring operation references a file.
        ///
        /// The SQE's `fd` field is a sum: either a raw file descriptor or a
        /// registered file index. The discriminant is `IOSQE_FIXED_FILE` in
        /// the entry flags. This enum makes the sum explicit — the flag/field
        /// agreement is compiler-enforced.
        ///
        /// ## Cases
        ///
        /// - `.descriptor`: A kernel file descriptor (the common case).
        /// - `.registered`: An index into the io_uring registered file table.
        ///   Sets `IOSQE_FIXED_FILE` automatically.
        /// - `.allocate`: Kernel auto-allocates a registered file slot
        ///   (`IORING_FILE_INDEX_ALLOC`). For accept-direct, openat-direct,
        ///   socket-direct. Sets both `IOSQE_FIXED_FILE` and `file_index = ~0`.
        public enum Target: ~Copyable {
            /// A kernel file descriptor.
            case descriptor(Kernel.Descriptor)

            /// An index into the registered file table.
            case registered(UInt32)

            /// Kernel auto-allocates a registered file slot.
            case allocate
        }
    }

    // MARK: - SQE Application

    extension Kernel.IO.Uring.Target {
        /// Write the target's fd value to the SQE.
        func apply(
            to sqe: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>
        ) {
            switch self {
            case .descriptor(let fd):
                unsafe (sqe.pointee.cValue.fd = fd._rawValue)

            case .registered(let index):
                unsafe (sqe.pointee.cValue.fd = Int32(bitPattern: index))
                unsafe (sqe.pointee.flags.insert(.fixedFile))

            case .allocate:
                unsafe (sqe.pointee.cValue.fd = Int32(bitPattern: UInt32.max))
                unsafe (sqe.pointee.flags.insert(.fixedFile))
            }
        }
    }

#endif
