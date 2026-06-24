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
    public import Error_Primitives

    extension ISO_9945.Kernel.IO.Uring.Wakeup {
        /// Error during wakeup channel creation.
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// eventfd creation failed.
            case eventfd(Error_Primitives.Error.Code)

            /// io_uring eventfd registration failed.
            case register(Error_Primitives.Error.Code)
        }
    }

#endif
