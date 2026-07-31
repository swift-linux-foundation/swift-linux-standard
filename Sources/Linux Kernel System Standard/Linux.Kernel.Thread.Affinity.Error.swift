// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-linux-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Error_Primitives
public import Linux_Standard_Core

extension Linux.Kernel.Thread.Affinity {
    /// Errors from `sched_setaffinity(2)`.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Platform error from the underlying syscall.
        ///
        /// - POSIX: errno from `sched_setaffinity`
        case platform(Error_Primitives.Error.Code)
    }
}
