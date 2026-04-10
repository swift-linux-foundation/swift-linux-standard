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

    extension Kernel.IO.Uring.Sync {
        /// Flags for sync_file_range operations.
        ///
        /// Wraps SYNC_FILE_RANGE_* constants from `<fcntl.h>`.
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Wait for writeout of pages in the range that were dirty before the call.
            public static let waitBefore = Options(rawValue: UInt32(SYNC_FILE_RANGE_WAIT_BEFORE))

            /// Initiate writeout of pages in the range that are currently dirty.
            public static let write = Options(rawValue: UInt32(SYNC_FILE_RANGE_WRITE))

            /// Wait for writeout of pages in the range after writeback has been initiated.
            public static let waitAfter = Options(rawValue: UInt32(SYNC_FILE_RANGE_WAIT_AFTER))
        }
    }

#endif
