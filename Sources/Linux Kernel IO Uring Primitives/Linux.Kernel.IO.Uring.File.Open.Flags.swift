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

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.File {
        /// Flags for file open operations.
        ///
        /// Wraps O_* constants from `<fcntl.h>` and `<linux/io_uring.h>`.
        /// Used by openat and openat2 operations.
        public struct Open: Sendable {
            public struct Flags: OptionSet, Sendable {
                public let rawValue: Int32

                @inlinable
                public init(rawValue: Int32) {
                    self.rawValue = rawValue
                }

                /// Read only.
                public static let readOnly = Flags(rawValue: O_RDONLY)
                /// Write only.
                public static let writeOnly = Flags(rawValue: O_WRONLY)
                /// Read and write.
                public static let readWrite = Flags(rawValue: O_RDWR)
                /// Create file if it doesn't exist.
                public static let create = Flags(rawValue: O_CREAT)
                /// Fail if file already exists (with .create).
                public static let exclusive = Flags(rawValue: O_EXCL)
                /// Truncate existing file.
                public static let truncate = Flags(rawValue: O_TRUNC)
                /// Append mode.
                public static let append = Flags(rawValue: O_APPEND)
                /// Non-blocking mode.
                public static let nonBlock = Flags(rawValue: O_NONBLOCK)
                /// Close-on-exec flag.
                public static let closeOnExec = Flags(rawValue: O_CLOEXEC)
                /// Bypass page cache (direct I/O).
                public static let direct = Flags(rawValue: O_DIRECT)
                /// Write through (synchronous I/O for data).
                public static let dataSync = Flags(rawValue: O_DSYNC)
                /// Synchronous I/O (data + metadata).
                public static let sync = Flags(rawValue: O_SYNC)
            }
        }

        /// Flags for path-relative operations (statx, renameat, unlinkat, linkat).
        ///
        /// Wraps AT_* constants from `<fcntl.h>`.
        public struct At: Sendable {
            public struct Flags: OptionSet, Sendable {
                public let rawValue: UInt32

                @inlinable
                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                /// Do not follow symbolic links.
                public static let noFollow = Flags(rawValue: UInt32(AT_SYMLINK_NOFOLLOW))

                /// Allow empty path string.
                public static let emptyPath = Flags(rawValue: UInt32(AT_EMPTY_PATH))

                /// Follow symbolic links (for linkat).
                public static let symlinkFollow = Flags(rawValue: UInt32(AT_SYMLINK_FOLLOW))

                /// Remove directory instead of file (for unlinkat).
                public static let removeDirectory = Flags(rawValue: UInt32(AT_REMOVEDIR))
            }
        }

        /// Flags for rename operations.
        ///
        /// Wraps RENAME_* constants from `<linux/fs.h>`.
        public struct Rename: Sendable {
            public struct Flags: OptionSet, Sendable {
                public let rawValue: UInt32

                @inlinable
                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                /// Don't overwrite target if it exists.
                public static let noReplace = Flags(rawValue: UInt32(RENAME_NOREPLACE))

                /// Atomically exchange source and target.
                public static let exchange = Flags(rawValue: UInt32(RENAME_EXCHANGE))

                /// Create a whiteout object at the source.
                public static let whiteout = Flags(rawValue: UInt32(RENAME_WHITEOUT))
            }
        }

        /// Mode bits for fallocate.
        public struct Allocate: Sendable {
            public struct Mode: OptionSet, Sendable {
                public let rawValue: Int32

                @inlinable
                public init(rawValue: Int32) {
                    self.rawValue = rawValue
                }

                /// Default: allocate disk space.
                public static let none = Mode([])

                /// Deallocate space (punch hole). Combine with `.keepSize`.
                public static let punchHole = Mode(rawValue: 0x02) // FALLOC_FL_PUNCH_HOLE

                /// Don't modify the file's apparent size.
                public static let keepSize = Mode(rawValue: 0x01) // FALLOC_FL_KEEP_SIZE

                /// Remove range, collapsing file.
                public static let collapseRange = Mode(rawValue: 0x08) // FALLOC_FL_COLLAPSE_RANGE

                /// Zero-fill range.
                public static let zeroRange = Mode(rawValue: 0x10) // FALLOC_FL_ZERO_RANGE

                /// Insert range, shifting data.
                public static let insertRange = Mode(rawValue: 0x20) // FALLOC_FL_INSERT_RANGE

                /// Unshare shared extents.
                public static let unshareRange = Mode(rawValue: 0x40) // FALLOC_FL_UNSHARE_RANGE
            }
        }
    }

#endif
