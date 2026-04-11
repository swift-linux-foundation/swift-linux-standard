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
    /// I/O vector component of a message header.
    ///
    /// Each element in the pointed-to array describes one buffer segment.
    /// The memory must be layout-compatible with `struct iovec`.
    public struct Vectors: @unchecked Sendable {
        /// Pointer to the I/O vector array.
        public var pointer: UnsafeMutableRawPointer?

        /// Number of I/O vectors.
        public var count: Int

        /// Creates an I/O vector descriptor.
        ///
        /// - Parameters:
        ///   - pointer: Pointer to the I/O vector array.
        ///   - count: Number of I/O vectors.
        public init(pointer: UnsafeMutableRawPointer? = nil, count: Int = 0) {
            self.pointer = pointer
            self.count = count
        }
    }
}

#endif
