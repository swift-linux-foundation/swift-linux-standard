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

public import Kernel_Socket_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Socket {
    /// Socket type (maps to the POSIX "socket type" parameter of socket(2)).
    ///
    /// Named `Kind` because `Type` collides with Swift's metatype.
    public struct Kind: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension Kernel.Socket.Kind {
    /// Sequenced, reliable, two-way, connection-based byte stream (TCP).
    public static let stream = Self(rawValue: Int32(SOCK_STREAM.rawValue))

    /// Connectionless, unreliable messages of fixed maximum length (UDP).
    public static let datagram = Self(rawValue: Int32(SOCK_DGRAM.rawValue))

    /// Raw network protocol access.
    public static let raw = Self(rawValue: Int32(SOCK_RAW.rawValue))

    /// Sequenced, reliable, two-way connection-based datagrams.
    public static let sequencedPacket = Self(rawValue: Int32(SOCK_SEQPACKET.rawValue))
}

#endif
