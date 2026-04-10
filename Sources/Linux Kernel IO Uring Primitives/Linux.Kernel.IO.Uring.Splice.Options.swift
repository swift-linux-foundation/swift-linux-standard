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
        /// Flags for splice and tee operations.
        ///
        /// Wraps SPLICE_F_* constants from `<fcntl.h>`.
        public struct Splice: Sendable {
            public struct Options: OptionSet, Sendable {
                public let rawValue: UInt32

                @inlinable
                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                /// Attempt to move pages instead of copying.
                public static let move = Options(rawValue: UInt32(SPLICE_F_MOVE))

                /// Do not block on I/O.
                public static let nonblock = Options(rawValue: UInt32(SPLICE_F_NONBLOCK))

                /// Hint that more data will follow.
                public static let more = Options(rawValue: UInt32(SPLICE_F_MORE))

                /// Splicing to/from a registered file descriptor.
                public static let fixedDescriptor = Options(rawValue: 1 << 31) // SPLICE_F_FD_IN_FIXED
            }
        }
    }

#endif
