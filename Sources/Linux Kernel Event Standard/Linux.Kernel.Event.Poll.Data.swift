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
    public import Error_Primitives

    extension ISO_9945.Kernel.Event.Poll {
        /// Opaque data associated with an epoll event.
        ///
        /// Poll data is a 64-bit value that the kernel returns unchanged
        /// when the event fires. This is used to route events to their handlers.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Use as an identifier
        /// let data = ISO_9945.Kernel.Event.Poll.Data(id)
        ///
        /// // Use with pointer-based context lookup
        /// let data = ISO_9945.Kernel.Event.Poll.Data(pointer: contextPtr)
        /// ```
        public typealias Data = Tagged<ISO_9945.Kernel.Event.Poll, UInt64>
    }

    // MARK: - Pointer Conversions

    extension ISO_9945.Kernel.Event.Poll.Data {
        /// Creates poll data from a raw pointer.
        ///
        /// This is useful when you want to associate a context object
        /// with an event.
        ///
        /// - Parameter pointer: A pointer to associate with the event.
        @unsafe
        public init(_ pointer: UnsafeRawPointer) {
            self.init(_unchecked: UInt64(UInt(bitPattern: unsafe pointer)))
        }

        /// Creates poll data from a typed pointer.
        ///
        /// - Parameter pointer: A pointer to associate with the event.
        @unsafe
        public init<T>(pointer: UnsafePointer<T>) {
            self.init(_unchecked: UInt64(UInt(bitPattern: unsafe pointer)))
        }

        /// Creates poll data from a mutable typed pointer.
        ///
        /// - Parameter pointer: A mutable pointer to associate with the event.
        @unsafe
        public init<T>(pointer: UnsafeMutablePointer<T>) {
            self.init(_unchecked: UInt64(UInt(bitPattern: unsafe pointer)))
        }
    }

    // MARK: - Common Values

    extension ISO_9945.Kernel.Event.Poll.Data {
        /// Zero poll data.
        public static let zero: Self = .init(_unchecked: 0)
    }

#endif
