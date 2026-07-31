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

extension Linux.Kernel.Event {
    /// Readiness categories for descriptor monitoring, projected onto epoll.
    ///
    /// Local mirror of the request-side readiness categories consumed by
    /// ``Linux/Kernel/Event/Poll/Events/init(interest:)``. The cross-platform
    /// vocabulary now lives at L3 in `Kernel.Event.Interest` (swift-kernel);
    /// this package-local type exists solely so the epoll projection
    /// initializer does not require the L3 unifier's vocabulary type
    /// (swift-iso/swift-iso-9945#64 / [PLAT-ARCH] layer-follows-essence).
    public struct Interest: OptionSet, Sendable, Hashable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

extension Linux.Kernel.Event.Interest {
    /// Interest in read readiness (data available to read).
    public static let read = Self(rawValue: 1 << 0)

    /// Interest in write readiness (buffer space available for writing).
    public static let write = Self(rawValue: 1 << 1)

    /// Interest in priority/out-of-band data (platform-specific).
    public static let priority = Self(rawValue: 1 << 2)
}
