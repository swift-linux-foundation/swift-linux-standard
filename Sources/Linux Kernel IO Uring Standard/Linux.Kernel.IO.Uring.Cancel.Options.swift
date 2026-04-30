// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)
    public import Kernel_IO_Primitives
    public import Error_Primitives
    public import Memory_Primitives

    extension Kernel.IO.Uring.Cancel {
        /// Flags controlling how cancel operations match their targets.
        ///
        /// These flags determine the matching strategy for cancelling
        /// in-flight io_uring operations. By default, cancel matches
        /// a single operation by user data. These flags extend matching
        /// to file descriptors, opcodes, or broader scopes.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Cancel all operations matching a file descriptor
        /// let options: Kernel.IO.Uring.Cancel.Options = [.all, .fd]
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring/Cancel``
        public struct Options: OptionSet, Sendable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            /// Cancel all matching requests, not just the first.
            ///
            /// Without this flag, only the first matching operation is
            /// cancelled. With it, all operations matching the criteria
            /// are cancelled.
            ///
            /// - Linux: `IORING_ASYNC_CANCEL_ALL`
            public static let all = Options(rawValue: 1 << 0)

            /// Match cancel target by file descriptor.
            ///
            /// The `addr` field is interpreted as a file descriptor
            /// rather than user data for matching purposes.
            ///
            /// - Linux: `IORING_ASYNC_CANCEL_FD`
            public static let fd = Options(rawValue: 1 << 1)

            /// Cancel any single request.
            ///
            /// Ignores matching criteria entirely and cancels an
            /// arbitrary in-flight operation.
            ///
            /// - Linux: `IORING_ASYNC_CANCEL_ANY`
            public static let any = Options(rawValue: 1 << 2)

            /// Match cancel target by fixed file index.
            ///
            /// Like `.fd`, but the value refers to a registered fixed
            /// file slot rather than a raw file descriptor.
            ///
            /// - Linux: `IORING_ASYNC_CANCEL_FD_FIXED`
            public static let fdFixed = Options(rawValue: 1 << 3)

            /// Match cancel target by user data.
            ///
            /// Explicitly selects user data matching. This is the default
            /// behavior when no matching flags are specified.
            ///
            /// - Linux: `IORING_ASYNC_CANCEL_USERDATA`
            public static let userData = Options(rawValue: 1 << 4)

            /// Match cancel target by opcode.
            ///
            /// Cancels operations that match the specified opcode,
            /// allowing bulk cancellation of a specific operation type.
            ///
            /// - Linux: `IORING_ASYNC_CANCEL_OP`
            public static let op = Options(rawValue: 1 << 5)
        }
    }

#endif
