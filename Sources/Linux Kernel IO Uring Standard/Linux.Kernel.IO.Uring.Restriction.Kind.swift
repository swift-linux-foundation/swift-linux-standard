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

    extension Kernel.IO.Uring {
        /// Ring restriction types for sandboxing.
        ///
        /// Used with `Register.Restriction.register` to limit which
        /// operations are permitted on a ring.
        public enum Restriction {}
    }

    extension Kernel.IO.Uring.Restriction {
        /// The kind of restriction to apply.
        public enum Kind: UInt16, Sendable {
            /// Restrict which register opcodes are allowed.
            ///
            /// - Linux: `IORING_RESTRICTION_REGISTER_OP`
            case registerOperation = 0

            /// Restrict which SQE opcodes are allowed.
            ///
            /// - Linux: `IORING_RESTRICTION_SQE_OP`
            case entryOperation = 1

            /// Restrict which SQE flags are allowed.
            ///
            /// - Linux: `IORING_RESTRICTION_SQE_FLAGS_ALLOWED`
            case entryFlagsAllowed = 2

            /// Require specific SQE flags on every submission.
            ///
            /// - Linux: `IORING_RESTRICTION_SQE_FLAGS_REQUIRED`
            case entryFlagsRequired = 3
        }
    }

#endif
