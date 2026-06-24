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

public import ISO_9945_Core
public import ISO_9945_Kernel_File
    public import Binary_Primitives

    extension ISO_9945.Kernel.IO.Uring {
        /// Buffer length for io_uring operations.
        ///
        /// A type-safe 32-bit length value using the Dimension pattern.
        /// Follows the same pattern as `ISO_9945.Kernel.File.Size`.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // From an integer literal
        /// let length: ISO_9945.Kernel.IO.Uring.Length = 4096
        ///
        /// // From a File.Size
        /// let length = ISO_9945.Kernel.IO.Uring.Length(fileSize)
        ///
        /// // From a buffer pointer
        /// let length = ISO_9945.Kernel.IO.Uring.Length(buffer)
        /// ```
        public typealias Length = Magnitude<Space>.Value<UInt32>
    }

    // MARK: - Convenience Initializers

    extension ISO_9945.Kernel.IO.Uring.Length {
        /// Zero length.
        public static let zero: Self = .init(UInt32(0))

        /// Creates a length from an integer.
        ///
        /// Values larger than `UInt32.max` are clamped.
        ///
        /// - Parameter count: The length in bytes.
        public init(_ count: Int) {
            self.init(UInt32(clamping: count))
        }

        /// Creates a length from a buffer pointer.
        ///
        /// - Parameter buffer: The buffer whose count to use.
        @unsafe
        public init(_ buffer: UnsafeRawBufferPointer) {
            self.init(UInt32(clamping: unsafe buffer.count))
        }

        /// Creates a length from a mutable buffer pointer.
        ///
        /// - Parameter buffer: The buffer whose count to use.
        @unsafe
        public init(_ buffer: UnsafeMutableRawBufferPointer) {
            self.init(UInt32(clamping: unsafe buffer.count))
        }

        /// Creates a length from a Span.
        ///
        /// This is the safe, normative API for creating a Length from contiguous storage.
        ///
        /// - Parameter span: The span whose count to use.
        public init(_ span: Swift.Span<UInt8>) {
            self.init(UInt32(clamping: span.count))
        }

        /// Creates a length from a MutableSpan.
        ///
        /// This is the safe, normative API for creating a Length from mutable contiguous storage.
        ///
        /// - Parameter span: The mutable span whose count to use.
        public init(_ span: borrowing MutableSpan<UInt8>) {
            self.init(UInt32(clamping: span.count))
        }
    }

    // MARK: - File.Size Conversion

    extension ISO_9945.Kernel.IO.Uring.Length {
        /// Creates a Length from a File.Size.
        ///
        /// Saturates at `UInt32.max` for sizes larger than 4GB.
        public init(_ size: ISO_9945.Kernel.File.Size) {
            if size.underlying > Int64(UInt32.max) {
                self.init(UInt32.max)
            } else if size.underlying < 0 {
                self.init(UInt32(0))
            } else {
                self.init(UInt32(size.underlying))
            }
        }
    }

#endif
