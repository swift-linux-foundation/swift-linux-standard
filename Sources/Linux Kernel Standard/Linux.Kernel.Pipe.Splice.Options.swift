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

public import Kernel_Primitives_Core
public import Kernel_Descriptor_Primitives
public import Kernel_Error_Primitives
public import Kernel_File_Primitives
public import Kernel_Memory_Primitives
public import Kernel_Random_Primitives
public import Kernel_Path_Primitives

#if canImport(CLinuxKernelShim)
    internal import CLinuxKernelShim
#endif

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux Splice Flags

extension Kernel.Pipe {
    /// Linux splice operations.
    ///
    /// Namespace for splice(2) and tee(2) related types.
    public struct Splice: Sendable {
        /// Flags for splice and tee operations.
        ///
        /// Wraps SPLICE_F_* constants from `<fcntl.h>`.
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Attempt to move pages instead of copying.
            public static let move = Self(rawValue: UInt32(SPLICE_F_MOVE))

            /// Do not block on I/O.
            public static let nonblock = Self(rawValue: UInt32(SPLICE_F_NONBLOCK))

            /// Hint that more data will follow.
            public static let more = Self(rawValue: UInt32(SPLICE_F_MORE))
        }
    }
}

#endif
