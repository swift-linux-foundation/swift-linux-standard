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

    extension Kernel.IO.Uring.Pipe {
        /// Flags for pipe creation.
        ///
        /// Wraps O_* constants applicable to pipe2().
        public struct Flags: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Non-blocking pipe.
            public static let nonBlock = Flags(rawValue: UInt32(O_NONBLOCK))

            /// Close-on-exec flag.
            public static let closeOnExec = Flags(rawValue: UInt32(O_CLOEXEC))

            /// Direct I/O for pipe.
            public static let direct = Flags(rawValue: UInt32(O_DIRECT))
        }
    }

#endif
