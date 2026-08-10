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
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    // MARK: - IORING_FIXED_FD_NO_CLOEXEC
    //
    // Some CI toolchain images (e.g. Swift 6.4.x-nightly) ship kernel/liburing
    // headers that predate this constant, so it is not always available from
    // Linux_Kernel_Shims. Defined locally with the documented kernel value,
    // matching the FICLONE convention in Linux.Kernel.File.Clone.swift.
    private let _IORING_FIXED_FD_NO_CLOEXEC: UInt32 = 1 << 0

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
                public static let noCloseOnExec = Options(rawValue: _IORING_FIXED_FD_NO_CLOEXEC)
            }
        }
    }

#endif
