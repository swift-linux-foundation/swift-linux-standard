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

    // MARK: - IORING_MSG_RING_CQE_SKIP / IORING_MSG_RING_FLAGS_PASS
    //
    // Some CI toolchain images (e.g. Swift 6.4.x-nightly) ship kernel/liburing
    // headers that predate these constants, so they are not always available
    // from Linux_Kernel_Shims. Defined locally with the documented kernel
    // values, matching the FICLONE convention in Linux.Kernel.File.Clone.swift.
    private let _IORING_MSG_RING_CQE_SKIP: UInt32 = 1 << 0
    private let _IORING_MSG_RING_FLAGS_PASS: UInt32 = 1 << 1

    extension ISO_9945.Kernel.IO.Uring {
        /// Types for io_uring MSG_RING operations (inter-ring messaging).
        public struct Message: Sendable {
            /// Flags controlling MSG_RING behavior.
            public struct Options: OptionSet, Sendable {
                public let rawValue: UInt32

                @inlinable
                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                /// Skip CQE on the source ring for this message.
                public static let cqeSkip = Options(rawValue: _IORING_MSG_RING_CQE_SKIP)

                /// Pass flags from the source SQE to the target CQE.
                public static let flagsPass = Options(rawValue: _IORING_MSG_RING_FLAGS_PASS)
            }
        }
    }

#endif
