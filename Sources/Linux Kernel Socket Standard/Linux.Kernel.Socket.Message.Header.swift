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

extension Kernel.Socket.Message {
    /// Message header for sendmsg/recvmsg operations.
    ///
    /// Wraps the platform `msghdr` struct. Layout-compatible — an
    /// `UnsafePointer<Header>` may be passed directly to kernel interfaces
    /// that expect `struct msghdr *`.
    public struct Header: @unchecked Sendable {
        /// The underlying C struct.
        internal var cValue: msghdr

        /// Creates a zeroed message header.
        public init() {
            self.cValue = msghdr()
        }
    }
}

// MARK: - Accessors

extension Kernel.Socket.Message.Header {
    /// Socket address for the message destination (sendmsg) or source (recvmsg).
    public var name: Name {
        get { Name(pointer: cValue.msg_name, length: cValue.msg_namelen) }
        set {
            cValue.msg_name = newValue.pointer
            cValue.msg_namelen = newValue.length
        }
    }

    /// Scatter/gather I/O vectors.
    public var vectors: Vectors {
        get {
            Vectors(
                pointer: cValue.msg_iov.map(UnsafeMutableRawPointer.init),
                count: cValue.msg_iovlen
            )
        }
        set {
            cValue.msg_iov = unsafe newValue.pointer?.assumingMemoryBound(to: iovec.self)
            cValue.msg_iovlen = newValue.count
        }
    }

    /// Ancillary data (control messages).
    public var control: Control {
        get { Control(pointer: cValue.msg_control, length: cValue.msg_controllen) }
        set {
            cValue.msg_control = newValue.pointer
            cValue.msg_controllen = newValue.length
        }
    }

    /// Flags on received message (output only, set by recvmsg).
    public var flags: Int32 {
        get { cValue.msg_flags }
        set { cValue.msg_flags = newValue }
    }
}

#endif
