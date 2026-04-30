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

    extension ISO_9945.Kernel.IO.Uring.Opcode.Ring.Command {
        /// Flags for uring command operations (`IORING_OP_URING_CMD`).
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode.Ring.Command.Options {
        /// Use a fixed (registered) file descriptor for the command.
        ///
        /// - Linux: `IORING_URING_CMD_FIXED`
        public static let fixed = Self(rawValue: 1 << 0)
    }

#endif
