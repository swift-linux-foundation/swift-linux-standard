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
    /// Ancillary data (control message) component of a message header.
    public struct Control: @unchecked Sendable {
        /// Pointer to the ancillary data buffer.
        public var pointer: UnsafeMutableRawPointer?

        /// Length of the ancillary data buffer in bytes.
        public var length: Int

        /// Creates an ancillary data descriptor.
        ///
        /// - Parameters:
        ///   - pointer: Pointer to the ancillary data buffer.
        ///   - length: Length of the ancillary data buffer in bytes.
        public init(pointer: UnsafeMutableRawPointer? = nil, length: Int = 0) {
            self.pointer = pointer
            self.length = length
        }
    }
}

#endif
