// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

public import ISO_9945_Core
public import ISO_9945_Kernel_File
    public import Error_Primitives
    public import Memory_Primitives
    public import Path_Primitives

    extension ISO_9945.Kernel.File.Rename {
        /// Options for renameat2(2).
        ///
        /// Controls the behavior of atomic rename operations.
        public struct Options: OptionSet, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Don't overwrite destination if it exists.
            ///
            /// The rename fails with EEXIST if the destination already exists.
            /// Provides atomic "create if not exists" semantics.
            public static let noreplace = Self(rawValue: 1)  // RENAME_NOREPLACE

            /// Atomically exchange source and destination.
            ///
            /// Both paths must exist. The operation atomically swaps
            /// the two directory entries.
            public static let exchange = Self(rawValue: 2)  // RENAME_EXCHANGE

            /// Create a whiteout at source (overlayfs).
            ///
            /// Used by overlay filesystems to mark a file as deleted
            /// in the upper layer while it still exists in lower layers.
            public static let whiteout = Self(rawValue: 4)  // RENAME_WHITEOUT
        }
    }

#endif
