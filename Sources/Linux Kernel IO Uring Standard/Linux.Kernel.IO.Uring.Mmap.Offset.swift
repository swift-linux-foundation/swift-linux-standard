// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Mmap {
        /// Mmap offsets for io_uring ring buffers.
        ///
        /// These magic offset values are passed to `mmap()` to map different
        /// parts of the io_uring ring structure:
        ///
        /// - `sqRing`: Maps the submission queue ring (head, tail, mask, flags, array)
        /// - `cqRing`: Maps the completion queue ring (head, tail, mask, cqes)
        /// - `sqes`: Maps the submission queue entry array
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Map the SQ ring
        /// let sqRingPtr = try Memory.Map.map(
        ///     length: sqRingSize,
        ///     protection: .readWrite,
        ///     flags: .shared,
        ///     fd: ringFd,
        ///     offset: ISO_9945.Kernel.IO.Uring.Mmap.Offset.sqRing
        /// )
        /// ```
        public enum Offset {
            /// Offset for mapping the submission queue ring.
            ///
            /// Value: `IORING_OFF_SQ_RING` (0)
            public static let sqRing: Int64 = 0

            /// Offset for mapping the completion queue ring.
            ///
            /// Value: `IORING_OFF_CQ_RING` (0x8000000)
            public static let cqRing: Int64 = 0x8000000

            /// Offset for mapping the submission queue entries array.
            ///
            /// Value: `IORING_OFF_SQES` (0x10000000)
            public static let sqes: Int64 = 0x1000_0000

            /// Offset for mapping a provided buffer ring.
            ///
            /// The buffer group ID is encoded in the upper bits via
            /// `providedBufferShift`.
            ///
            /// Value: `IORING_OFF_PBUF_RING` (0x80000000)
            public static let providedBufferRing: Int64 = 0x8000_0000

            /// Bit shift for encoding the buffer group ID in the mmap offset.
            ///
            /// Value: `IORING_OFF_PBUF_SHIFT` (16)
            public static let providedBufferShift: Int64 = 16

            /// Mask for extracting the mmap region type from an offset.
            ///
            /// Value: `IORING_OFF_MMAP_MASK` (0xF8000000)
            public static let mask: Int64 = 0xF800_0000
        }
    }

#endif
