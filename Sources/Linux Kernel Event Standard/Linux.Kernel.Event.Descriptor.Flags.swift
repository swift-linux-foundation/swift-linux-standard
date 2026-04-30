// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)
public import Error_Primitives

extension Kernel.Event.Descriptor {
    /// Flags for event descriptor creation.
    ///
    /// ## Platform Implementation
    ///
    /// Flag constants are in platform-specific packages:
    /// - Linux: `swift-linux-primitives` (`Linux_Kernel_Event_Standard`)
    public struct Flags: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// No flags.
        public static let none = Flags(rawValue: 0)

        /// Combines multiple flags.
        @inlinable
        public static func | (lhs: Flags, rhs: Flags) -> Flags {
            Flags(rawValue: lhs.rawValue | rhs.rawValue)
        }
    }
}

#endif

