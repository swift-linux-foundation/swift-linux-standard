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
    /// Network protocol for socket(2).
    ///
    /// Wraps `IPPROTO_*` constants. Use `.auto` (0) to let the kernel
    /// select the default protocol for the given domain and socket kind.
    public struct `Protocol`: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension Kernel.Socket.`Protocol` {
    /// Kernel selects the default protocol for the domain and kind.
    public static let auto = Self(rawValue: 0)

    /// Transmission Control Protocol.
    public static let tcp = Self(rawValue: Int32(IPPROTO_TCP))

    /// User Datagram Protocol.
    public static let udp = Self(rawValue: Int32(IPPROTO_UDP))

    /// Raw IP packets.
    public static let raw = Self(rawValue: Int32(IPPROTO_RAW))

    /// Stream Control Transmission Protocol.
    public static let sctp = Self(rawValue: Int32(IPPROTO_SCTP))
}

#endif
