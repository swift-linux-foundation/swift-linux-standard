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

public import Linux_Standard_Core

extension Linux.Kernel {
    /// Linux kernel file mechanisms — namespace root for the platform
    /// mechanism surface nested below (for example ``Linux/Kernel/File/Clone``).
    ///
    /// Package-local namespace root for the platform mechanism surface
    /// previously anchored on the hoisted `ISO_9945.Kernel.File.Direct` and
    /// `ISO_9945.Kernel.File.Clone` vocabulary families
    /// (swift-iso/swift-iso-9945#64). The unified cross-platform vocabulary
    /// now lives at L3 in `Kernel.File` (swift-kernel).
    public enum File: Sendable {}
}
