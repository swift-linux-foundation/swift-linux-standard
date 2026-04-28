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
        /// `~Escapable`: Target borrows the descriptor's lifetime — it cannot
        /// outlive the descriptor it references. The kernel fd number is safe
        /// because the lifetime system guarantees the descriptor stays open.
        ///
        /// ## Cases
        ///
        /// - `.descriptor`: A kernel file descriptor (the common case).
        ///   Created via ``init(descriptor:)`` which borrows the descriptor.
        /// - `.registered`: An index into the io_uring registered file table.
        ///   Sets `IOSQE_FIXED_FILE` automatically.
        /// - `.allocate`: Kernel auto-allocates a registered file slot
        ///   (`IORING_FILE_INDEX_ALLOC`). For accept-direct, openat-direct,
        ///   socket-direct. Sets both `IOSQE_FIXED_FILE` and `file_index = ~0`.
        public enum Target: ~Copyable, ~Escapable {
            /// A kernel file descriptor (raw fd number).
            ///
            /// The fd is safe to use because Target's `~Escapable` constraint
            /// ties it to the borrowed descriptor's lifetime.
            case descriptor(Int32)

            /// An index into the registered file table.
            case registered(UInt32)

            /// Kernel auto-allocates a registered file slot.
            case allocate

            /// No file descriptor — sets fd to -1.
            ///
            /// Used by operations that don't target a file: timeout, cancel,
            /// poll remove, files update, madvise, pipe, and similar.
            case none
        }
    }

    // MARK: - Typed Construction (Phase 1.5)

    extension Kernel.IO.Uring.Target {
        /// Creates a descriptor target by borrowing a typed descriptor.
        ///
        /// Phase 1.5 typed L2 form. The target borrows the descriptor's
        /// lifetime via `@_lifetime(borrow descriptor)` — it cannot outlive
        /// the descriptor. The raw fd number is extracted at construction
        /// and is safe to use for the SQE because the descriptor stays open.
        ///
        /// The public enum case `Target.descriptor(Int32)` remains the
        /// spec-literal raw constructor.
        @_lifetime(borrow descriptor)
        public init(descriptor: borrowing Kernel.Descriptor) {
            self = .descriptor(descriptor._rawValue)
        }
    }

    // MARK: - SQE Application

    extension Kernel.IO.Uring.Target {
        /// Write the target's fd value and flags to the SQE.
        @usableFromInline
        func apply(
            to sqe: inout Kernel.IO.Uring.Submission.Queue.Entry
        ) {
            switch self {
            case .descriptor(let fd):
                sqe._fd = fd

            case .registered(let index):
                sqe._fd = Int32(bitPattern: index)
                sqe.flags.insert(.fixedFile)

            case .allocate:
                sqe._fd = Int32(bitPattern: UInt32.max)
                sqe.flags.insert(.fixedFile)

            case .none:
                sqe._fd = -1
            }
        }
    }

#endif
