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
    public import Kernel_IO_Primitives
    public import Kernel_Descriptor_Primitives
    public import Kernel_Error_Primitives
    public import Kernel_Memory_Primitives
    public import Kernel_File_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.Completion.Queue {
        /// Swift wrapper for io_uring completion queue entry.
        ///
        /// An Entry contains the result of a completed I/O operation.
        /// This wrapper provides a Swift-native interface to the C `io_uring_cqe` struct.
        ///
        /// ## Usage
        ///
        /// Entries are read from the completion queue ring buffer:
        /// ```swift
        /// let entryPtr = ring.cqes.advanced(by: index)
        /// let entry = Kernel.IO.Uring.Completion.Queue.Entry(entryPtr.pointee)
        /// if entry.isSuccess {
        ///     print("Completed: \(entry.result) bytes")
        /// }
        /// ```
        ///
        /// ## Thread Safety
        ///
        /// Entries are value types that wrap a C struct. They should be read
        /// on the poll thread from the shared ring buffer.
        public struct Entry: Sendable {
            /// The underlying C struct.
            internal let cValue: io_uring_cqe

            /// Creates an Entry from a C struct.
            internal init(_ cValue: io_uring_cqe) {
                self.cValue = cValue
            }
        }
    }

    // MARK: - Accessors

    extension Kernel.IO.Uring.Completion.Queue.Entry {
        /// Operation data from the corresponding submission queue entry.
        ///
        /// This is the value set via `entry.data` when the operation was submitted.
        /// Typically used to recover the operation context (e.g., a pointer to Storage).
        public var data: Kernel.IO.Uring.Operation.Data {
            Kernel.IO.Uring.Operation.Data(__unchecked: (), cValue.user_data)
        }

        /// Raw result of the operation.
        ///
        /// Negative values are negated errno codes. Non-negative values
        /// are operation-specific success results (bytes transferred, fd, etc.).
        ///
        /// Prefer ``isSuccess`` and ``error`` for typed access.
        @usableFromInline
        internal var res: Int32 {
            cValue.res
        }

        /// Entry flags.
        ///
        /// Contains additional information about the completion.
        public var flags: Options {
            Options(rawValue: cValue.flags)
        }
    }

    // MARK: - Result Interpretation

    extension Kernel.IO.Uring.Completion.Queue.Entry {
        /// Whether the operation completed successfully.
        public var isSuccess: Bool {
            res >= 0
        }

        /// Whether the operation failed.
        public var isError: Bool {
            res < 0
        }

        /// Whether the operation was cancelled.
        public var isCancelled: Bool {
            res == -Int32(ECANCELED)
        }

        /// The error number (for failed operations).
        ///
        /// Returns nil if the operation succeeded.
        public var errorNumber: Kernel.Error.Number? {
            isError ? Kernel.Error.Number(__unchecked: (), -res) : nil
        }
    }

#endif
