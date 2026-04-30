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
    public import Dimension_Primitives

    public import Binary_Primitives_Core

    extension ISO_9945.Kernel.IO.Uring {
        /// File offset for io_uring operations.
        ///
        /// A type-safe coordinate for io_uring file positions.
        /// Uses UInt64 where `UInt64.max` indicates "use current file position".
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Read at a specific offset
        /// ring.next.entry.read(target: .descriptor(fd), buffer: buf, length: len, offset: .zero, data: id)
        ///
        /// // Read at current file position
        /// ring.next.entry.read(target: .descriptor(fd), buffer: buf, length: len, offset: .current, data: id)
        /// ```
        public typealias Offset = Coordinate.X<Space>.Value<UInt64>
    }

    // MARK: - Offset Constants

    extension ISO_9945.Kernel.IO.Uring.Offset {
        /// Zero offset (beginning of file).
        public static let zero: Self = .init(UInt64(0))

        /// Use current file position.
        ///
        /// When passed to read/write operations, the operation uses
        /// the file descriptor's current position.
        public static let current = Self(UInt64.max)
    }

    // MARK: - Cross-Space Conversion

    extension ISO_9945.Kernel.IO.Uring.Offset {
        /// Creates an io_uring offset from a file offset.
        ///
        /// Negative file offsets (indicating "current position") are
        /// converted to `.current` (UInt64.max).
        public init(_ fileOffset: ISO_9945.Kernel.File.Offset) {
            if fileOffset.rawValue >= 0 {
                self.init(UInt64(fileOffset.rawValue))
            } else {
                self = .current
            }
        }
    }

    // MARK: - CustomStringConvertible

    extension ISO_9945.Kernel.IO.Uring.Offset: CustomStringConvertible {
        public var description: Swift.String {
            if self == .current {
                return "current"
            }
            return "\(rawValue)"
        }
    }

#endif
