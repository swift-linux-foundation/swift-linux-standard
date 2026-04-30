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

    extension ISO_9945.Kernel.IO.Uring {
        /// Ring restriction types for sandboxing.
        ///
        /// Used with `Register.Restriction.register` to limit which
        /// operations are permitted on a ring.
        public enum Restriction {}
    }

#endif
