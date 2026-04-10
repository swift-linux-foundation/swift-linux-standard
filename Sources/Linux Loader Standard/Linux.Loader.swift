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

#if os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)

@_exported public import Linux_Standard_Core
@_exported public import Loader_Primitives

extension Linux_Standard_Core.Linux {
    /// Linux dynamic loader interface.
    ///
    /// Provides access to Linux-specific loader functionality including:
    /// - Section enumeration via `swift_enumerateAllMetadataSections`
    ///
    /// ## Implementation
    ///
    /// Uses the Swift runtime's metadata section enumeration to discover
    /// sections across all loaded ELF images.
    public enum Loader: Sendable {}
}

#endif
