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

    extension Kernel.IO.Uring.Nop {
        /// Flags for NOP operations.
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Kernel.IO.Uring.Nop.Options {
        /// Inject a specific result value into the NOP completion.
        ///
        /// The CQE `res` field will contain the value from the
        /// SQE's `len` field instead of the default 0.
        ///
        /// - Linux: `IORING_NOP_INJECT_RESULT`
        public static let injectResult = Self(rawValue: 1 << 0)
    }

#endif
