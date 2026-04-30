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

    extension ISO_9945.Kernel.IO.Uring {
        /// Phantom type tag for the io_uring byte space.
        ///
        /// Used to parameterize Dimension types for io_uring operations.
        /// IO.Uring uses UInt64 for offsets (with UInt64.max meaning "current position").
        public enum Space {}
    }

#endif
