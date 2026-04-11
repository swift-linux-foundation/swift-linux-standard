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

extension Kernel.Socket.Message.Header {
    /// Socket address component of a message header.
    public struct Name: @unchecked Sendable {
        /// Pointer to the socket address structure.
        public var pointer: UnsafeMutableRawPointer?

        /// Length of the socket address in bytes.
        public var length: UInt32

        /// Creates a socket address descriptor.
        ///
        /// - Parameters:
        ///   - pointer: Pointer to the socket address structure.
        ///   - length: Length of the socket address in bytes.
        public init(pointer: UnsafeMutableRawPointer? = nil, length: UInt32 = 0) {
            self.pointer = pointer
            self.length = length
        }
    }
}

#endif
