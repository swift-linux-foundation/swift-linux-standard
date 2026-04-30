// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

public import Error_Primitives
public import Memory_Primitives
public import Path_Primitives

#if canImport(CLinuxKernelShim)
    internal import CLinuxKernelShim
#endif

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux sync_file_range Flags

extension Kernel.File {
    /// Linux file sync operations.
    public struct Sync: Sendable {
        /// Range-based sync operations.
        ///
        /// Namespace for sync_file_range(2) related types.
        public struct Range: Sendable {
            /// Flags for sync_file_range operations.
            ///
            /// Wraps SYNC_FILE_RANGE_* constants from `<fcntl.h>`.
            public struct Options: OptionSet, Sendable {
                public let rawValue: UInt32

                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                /// Wait for writeout of pages in the range that were dirty before the call.
                public static let waitBefore = Self(rawValue: UInt32(SYNC_FILE_RANGE_WAIT_BEFORE))

                /// Initiate writeout of pages in the range that are currently dirty.
                public static let write = Self(rawValue: UInt32(SYNC_FILE_RANGE_WRITE))

                /// Wait for writeout of pages in the range after writeback has been initiated.
                public static let waitAfter = Self(rawValue: UInt32(SYNC_FILE_RANGE_WAIT_AFTER))
            }
        }
    }
}

#endif
