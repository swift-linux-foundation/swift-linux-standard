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

    extension Kernel.IO.Uring.Params {
        /// Kernel-reported feature flags from io_uring setup.
        ///
        /// These flags indicate which features the running kernel supports.
        /// Filled by the kernel during ``Kernel/IO/Uring/setup(entries:params:)``;
        /// not set by the application.
        public struct Features: Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    // MARK: - Feature Constants

    extension Kernel.IO.Uring.Params.Features {
        /// SQ and CQ rings can share a single mmap region.
        public static let singleMmap = Self(rawValue: 1 << 0)

        /// CQ overflow entries are not dropped.
        public static let noDrop = Self(rawValue: 1 << 1)

        /// Application can reuse SQE data buffers immediately after submission.
        public static let submitStable = Self(rawValue: 1 << 2)

        /// Read/write operations support current file position (-1 offset).
        public static let rwCurrentPosition = Self(rawValue: 1 << 3)

        /// Ring inherits the current personality for operations.
        public static let currentPersonality = Self(rawValue: 1 << 4)

        /// Internal fast poll mechanism for eligible operations.
        public static let fastPoll = Self(rawValue: 1 << 5)

        /// Full 32-bit poll event mask support.
        public static let poll32Bits = Self(rawValue: 1 << 6)

        /// SQ poll mode works without pre-registered fixed files.
        public static let sqPollNonFixed = Self(rawValue: 1 << 7)

        /// Extended argument support for enter syscall.
        public static let extArg = Self(rawValue: 1 << 8)

        /// Native io-wq worker pool.
        public static let nativeWorkers = Self(rawValue: 1 << 9)

        /// Resource tagging for registered buffers and files.
        public static let resourceTags = Self(rawValue: 1 << 10)

        /// CQE generation can be skipped for successful submissions.
        public static let cqeSkip = Self(rawValue: 1 << 11)

        /// Linked file descriptor support.
        public static let linkedFile = Self(rawValue: 1 << 12)

        /// Ring can be registered with another ring's descriptor.
        public static let regRegRing = Self(rawValue: 1 << 13)
    }

    // MARK: - Query

    extension Kernel.IO.Uring.Params.Features {
        /// Whether a specific feature is supported.
        @inlinable
        public func contains(_ feature: Self) -> Bool {
            rawValue & feature.rawValue == feature.rawValue
        }
    }

#endif
