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

    extension Kernel.IO.Uring.File {
        /// Allocation mode for fallocate operations.
        ///
        /// Each case represents a distinct kernel operation. The associated
        /// `keepSize` parameter (where applicable) controls whether the file's
        /// apparent size is updated.
        ///
        /// ## Operations
        ///
        /// | Mode | Effect | keepSize available? |
        /// |------|--------|-------------------|
        /// | `.allocate` | Pre-allocate disk space | Yes |
        /// | `.punch` | Deallocate (punch hole) | Always true (kernel requires it) |
        /// | `.collapse` | Remove range, shift data down | No |
        /// | `.zero` | Write zeros to range | Yes |
        /// | `.insert` | Insert empty range, shift data up | No |
        /// | `.unshare` | Unshare shared extents (CoW) | No |
        public enum Allocate: Sendable {
            public enum Mode: Sendable, Hashable {
                /// Pre-allocate disk space for the range.
                case allocate(keepSize: Bool = false)

                /// Deallocate space (punch hole). The file's apparent size is
                /// never changed — `keepSize` is implicit.
                case punch

                /// Remove the range and collapse the file.
                case collapse

                /// Write zeros to the range without changing block allocation.
                case zero(keepSize: Bool = false)

                /// Insert an empty range, shifting existing data up.
                case insert

                /// Unshare shared (CoW) extents, allocating private copies.
                case unshare
            }
        }
    }

    extension Kernel.IO.Uring.File.Allocate.Mode {
        /// The raw fallocate mode bits for the kernel.
        @usableFromInline
        var rawBits: Int32 {
            switch self {
            case .allocate(let keepSize):
                keepSize ? FALLOC_FL_KEEP_SIZE : 0
            case .punch:
                FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE
            case .collapse:
                FALLOC_FL_COLLAPSE_RANGE
            case .zero(let keepSize):
                FALLOC_FL_ZERO_RANGE | (keepSize ? FALLOC_FL_KEEP_SIZE : 0)
            case .insert:
                FALLOC_FL_INSERT_RANGE
            case .unshare:
                FALLOC_FL_UNSHARE_RANGE
            }
        }
    }

#endif
