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

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Kernel.IO.Uring {
        /// A typed I/O vector for scatter/gather operations.
        ///
        /// Wraps the kernel's `iovec` (base pointer + length). Used by vectored
        /// read/write operations (readv, writev) to describe multiple memory
        /// regions in a single operation.
        ///
        /// Binary-compatible with `struct iovec` from `<sys/uio.h>`.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// var vectors = [
        ///     Kernel.IO.Uring.Vector(base: buf1, length: 4096),
        ///     Kernel.IO.Uring.Vector(base: buf2, length: 1024),
        /// ]
        /// vectors.withUnsafeBufferPointer { vecs in
        ///     sqe.prepare.read(target: .descriptor(fd), vectors: vecs, offset: .zero, data: id)
        /// }
        /// ```
        public struct Vector: Sendable {
            /// Base address of the buffer.
            public var base: UnsafeMutableRawPointer?

            /// Length of the buffer in bytes.
            public var length: Int

            /// Creates an I/O vector from a mutable buffer pointer.
            @unsafe
            public init(base: UnsafeMutableRawPointer?, length: Int) {
                self.base = unsafe base
                self.length = length
            }

            /// Creates an I/O vector from a mutable raw buffer pointer.
            @unsafe
            public init(_ buffer: UnsafeMutableRawBufferPointer) {
                self.base = unsafe buffer.baseAddress
                self.length = buffer.count
            }

            /// Creates a read-only I/O vector from a raw buffer pointer.
            ///
            /// The base pointer is cast to mutable for kernel ABI compatibility;
            /// the kernel does not write to vectors used in write operations.
            @unsafe
            public init(_ buffer: UnsafeRawBufferPointer) {
                self.base = unsafe UnsafeMutableRawPointer(mutating: buffer.baseAddress)
                self.length = buffer.count
            }
        }
    }

    // MARK: - C Bridge

    extension Kernel.IO.Uring.Vector {
        /// The underlying C iovec representation.
        ///
        /// Binary-compatible — same layout as `struct iovec`.
        @inlinable
        var cValue: iovec {
            iovec(iov_base: unsafe base, iov_len: length)
        }

        /// Creates a Vector from a C iovec.
        @unsafe
        init(_ cValue: iovec) {
            self.base = unsafe cValue.iov_base
            self.length = cValue.iov_len
        }
    }

#endif
