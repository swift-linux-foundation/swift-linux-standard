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

public import ISO_9945_Core
public import ISO_9945_Kernel_Socket
#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Shutdown {
    /// Shutdown mode for shutdown(2).
    public struct Mode: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension ISO_9945.Kernel.Socket.Shutdown.Mode {
    /// Shut down the reading side of the socket.
    public static let read = Self(rawValue: Int32(SHUT_RD))

    /// Shut down the writing side of the socket.
    public static let write = Self(rawValue: Int32(SHUT_WR))

    /// Shut down both reading and writing.
    public static let both = Self(rawValue: Int32(SHUT_RDWR))
}

#endif
