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

extension Linux.Kernel.File.Clone.Error {
    /// Raw syscall-level errors from Linux clone/copy mechanisms.
    ///
    /// This type captures the exact errno from the underlying syscall.
    public enum Syscall: Swift.Error, Sendable {
        /// Platform syscall failure.
        case platform(code: Error_Primitives.Error.Code, operation: Operation)
    }
}
