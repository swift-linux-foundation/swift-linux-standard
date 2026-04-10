// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Linux_Standard_Core

extension Linux_Standard_Core.Linux.Memory {
    /// Allocation namespace for Linux memory allocation tracking.
    public enum Allocation: Sendable {}
}
