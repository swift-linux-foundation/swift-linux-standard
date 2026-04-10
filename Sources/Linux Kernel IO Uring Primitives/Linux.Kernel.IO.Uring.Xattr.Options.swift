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

    extension Kernel.IO.Uring.Xattr {
        /// Flags for extended attribute operations.
        ///
        /// Wraps XATTR_* constants from `<sys/xattr.h>`.
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Fail if the attribute already exists.
            public static let create = Options(rawValue: UInt32(XATTR_CREATE))

            /// Fail if the attribute does not exist.
            public static let replace = Options(rawValue: UInt32(XATTR_REPLACE))
        }
    }

#endif
