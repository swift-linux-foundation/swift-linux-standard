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
    public import Kernel_Error_Primitives

    extension Kernel.IO.Uring.Wakeup {
        /// Error during wakeup channel creation.
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// eventfd creation failed.
            case eventfd(Kernel.Error.Code)

            /// io_uring eventfd registration failed.
            case register(Kernel.Error.Code)
        }
    }

#endif
