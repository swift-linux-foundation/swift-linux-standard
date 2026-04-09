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

    @_spi(Syscall) public import Kernel_Primitives

    extension Kernel.Event.Poll {
        /// A typed epoll file descriptor.
        ///
        /// Zero-cost wrapper around `Kernel.Descriptor` that statically
        /// distinguishes epoll descriptors from other file descriptors.
        /// Instance methods replace the static `create`/`ctl`/`wait` API.
        ///
        /// Closing is automatic: when the descriptor goes out of scope,
        /// `Kernel.Descriptor.deinit` closes the underlying fd.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// let epoll = try Kernel.Event.Poll.Descriptor()
        /// try epoll.ctl(op: .add, fd: socketFd, event: event)
        /// let count = try epoll.wait(events: &events, timeout: .seconds(1))
        /// ```
        public typealias Descriptor = Tagged<Kernel.Event.Poll, Kernel.Descriptor>
    }

    // MARK: - Lifecycle

    extension Tagged where Tag == Kernel.Event.Poll, RawValue == Kernel.Descriptor {
        /// Creates a new epoll instance.
        ///
        /// - Parameter flags: Flags for the new epoll instance.
        /// - Throws: `Kernel.Event.Poll.Error.create` if creation fails.
        @inlinable
        public init(
            flags: Kernel.Event.Poll.Create.Flags = .cloexec
        ) throws(Kernel.Event.Poll.Error) {
            self.init(__unchecked: (), try Kernel.Event.Poll.create(flags: flags))
        }
    }

    // MARK: - Operations

    extension Tagged where Tag == Kernel.Event.Poll, RawValue == Kernel.Descriptor {
        /// Controls the epoll instance (add/modify/delete).
        ///
        /// - Parameters:
        ///   - op: The operation to perform.
        ///   - fd: The target file descriptor.
        ///   - event: The event structure (required for add/modify, ignored for delete).
        /// - Throws: `Kernel.Event.Poll.Error.ctl` if the operation fails.
        @inlinable
        public func ctl(
            op: Kernel.Event.Poll.Operation,
            fd: borrowing Kernel.Descriptor,
            event: Kernel.Event.Poll.Event? = nil
        ) throws(Kernel.Event.Poll.Error) {
            try Kernel.Event.Poll.ctl(self.rawValue, op: op, fd: fd, event: event)
        }

        /// Waits for events with a Duration timeout.
        ///
        /// - Parameters:
        ///   - events: Buffer for returned events.
        ///   - timeout: Timeout duration, or `nil` for infinite.
        /// - Returns: Number of events written to buffer, or 0 on timeout.
        /// - Throws: `Kernel.Event.Poll.Error.wait` on failure,
        ///   `.interrupted` on EINTR.
        @inlinable
        public func wait(
            events: inout [Kernel.Event.Poll.Event],
            timeout: Duration?
        ) throws(Kernel.Event.Poll.Error) -> Int {
            try Kernel.Event.Poll.wait(self.rawValue, events: &events, timeout: timeout)
        }
    }

#endif
