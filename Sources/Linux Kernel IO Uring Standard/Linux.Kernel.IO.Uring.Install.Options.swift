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

public import ISO_9945_Core
    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension ISO_9945.Kernel.IO.Uring.Fixed {
        /// Flags for fixed file descriptor installation.
        ///
        /// Wraps IORING_FIXED_FD_* constants.
        public struct Install: Sendable {
            public struct Options: OptionSet, Sendable {
                public let rawValue: UInt32

                @inlinable
                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                /// Don't set close-on-exec on the installed fd.
                public static let noCloseOnExec = Options(rawValue: UInt32(IORING_FIXED_FD_NO_CLOEXEC))
            }
        }
    }

#endif
