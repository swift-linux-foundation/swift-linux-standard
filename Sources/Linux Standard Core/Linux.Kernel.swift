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


public import ISO_9945_Core

extension Linux {
    /// Linux kernel mechanisms — typealias to the iso-9945 L2 `Kernel`
    /// namespace (G6.D typealias-via-L3 per [PLAT-ARCH-005]; Linux
    /// re-typealiases from iso-9945 since linux-standard depends on
    /// iso-9945 per [PLAT-ARCH-007]).
    public typealias Kernel = ISO_9945.Kernel
}
