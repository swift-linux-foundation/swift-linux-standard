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

#if canImport(Glibc) || canImport(Musl)

    extension Kernel.File.Rename {
        /// Flags for renameat2(2).
        ///
        /// Controls the behavior of atomic rename operations.
        public struct Flags: OptionSet, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Don't overwrite destination if it exists.
            ///
            /// The rename fails with EEXIST if the destination already exists.
            /// Provides atomic "create if not exists" semantics.
            public static let noreplace = Flags(rawValue: 1)  // RENAME_NOREPLACE

            /// Atomically exchange source and destination.
            ///
            /// Both paths must exist. The operation atomically swaps
            /// the two directory entries.
            public static let exchange = Flags(rawValue: 2)  // RENAME_EXCHANGE

            /// Create a whiteout at source (overlayfs).
            ///
            /// Used by overlay filesystems to mark a file as deleted
            /// in the upper layer while it still exists in lower layers.
            public static let whiteout = Flags(rawValue: 4)  // RENAME_WHITEOUT
        }
    }

#endif
