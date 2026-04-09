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

    @_spi(Syscall) public import Kernel_Event_Primitives
    @_spi(Syscall) public import Kernel_Descriptor_Primitives
    @_spi(Syscall) public import Kernel_Error_Primitives
    @_spi(Syscall) public import Kernel_Time_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.Event {
        /// Epoll event notification (Linux).
        ///
        /// Owns the epoll file descriptor via `~Copyable` — deinit closes
        /// the fd automatically. Instance methods provide the modern Swift API;
        /// package statics preserve the C API mirror for platform-stack internal use.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// var epoll = try Kernel.Event.Poll()
        /// try epoll.add(fd: socketFd, event: event)
        /// let count = try epoll.poll(events: &events, timeout: .seconds(1))
        /// // epoll deinit closes the epoll fd
        /// ```
        @safe
        public struct Poll: ~Copyable, Sendable {
            /// The underlying epoll file descriptor.
            @_spi(Syscall)
            public let descriptor: Kernel.Descriptor

            /// Creates a new epoll instance.
            ///
            /// - Parameter flags: Creation flags. Default: `.cloexec`.
            /// - Throws: `Error.create` if creation fails.
            public init(flags: Create.Flags = .cloexec) throws(Error) {
                self.descriptor = try Self.create(flags: flags)
            }
        }
    }

    // MARK: - Public Instance API

    extension Kernel.Event.Poll {
        /// Adds a file descriptor to the epoll instance.
        ///
        /// - Parameters:
        ///   - fd: The target file descriptor.
        ///   - event: The event structure describing interests.
        /// - Throws: `Error.ctl` on failure.
        public func add(
            fd: borrowing Kernel.Descriptor,
            event: Event
        ) throws(Error) {
            try Self.ctl(self, op: .add, fd: fd, event: event)
        }

        /// Modifies the events for a file descriptor.
        ///
        /// - Parameters:
        ///   - fd: The target file descriptor.
        ///   - event: The updated event structure.
        /// - Throws: `Error.ctl` on failure.
        public func modify(
            fd: borrowing Kernel.Descriptor,
            event: Event
        ) throws(Error) {
            try Self.ctl(self, op: .modify, fd: fd, event: event)
        }

        /// Removes a file descriptor from the epoll instance.
        ///
        /// - Parameter fd: The target file descriptor.
        /// - Throws: `Error.ctl` on failure.
        public func remove(
            fd: borrowing Kernel.Descriptor
        ) throws(Error) {
            try Self.ctl(self, op: .delete, fd: fd)
        }

        /// Waits for events.
        ///
        /// - Parameters:
        ///   - events: Buffer for returned events (pre-sized).
        ///   - timeout: Timeout duration, or `nil` for infinite.
        /// - Returns: Number of events written to buffer, or 0 on timeout.
        /// - Throws: `Error.wait` on failure, `.interrupted` on EINTR.
        public func poll(
            events: inout [Event],
            timeout: Duration?
        ) throws(Error) -> Int {
            try Self.wait(self, events: &events, timeout: timeout)
        }

        /// Registers an eventfd for wakeup signaling and returns a Sendable channel.
        ///
        /// Adds the eventfd to this epoll instance with `EPOLLIN | EPOLLET` and
        /// returns a channel whose `wake()` method signals the eventfd from any thread.
        /// Call before transferring the Poll to the poll thread via `sending`.
        ///
        /// - Parameter eventfd: The eventfd to register for wakeup signaling.
        /// - Returns: A Sendable wakeup channel.
        public func wakeup(
            eventfd: borrowing Kernel.Event.Descriptor
        ) throws(Error) -> Kernel.Wakeup.Channel {
            let wakeupEvent = Event(events: [.in, .et])
            try self.add(fd: eventfd.descriptor, event: wakeupEvent)
            let rawEfd = eventfd.descriptor._rawValue
            return Kernel.Wakeup.Channel {
                Kernel.Event.Descriptor.signal(rawDescriptor: rawEfd)
            }
        }
    }

    // MARK: - Package Statics (C API Mirror)

    extension Kernel.Event.Poll {
        /// Creates a new epoll instance.
        package static func create(flags: Create.Flags = .cloexec) throws(Kernel.Event.Poll.Error) -> Kernel.Descriptor {
            let epfd = epoll_create1(flags.rawValue)
            guard epfd >= 0 else {
                throw .create(.posix(errno))
            }
            return Kernel.Descriptor(_rawValue: epfd)
        }

        /// Controls the epoll instance (add/modify/delete).
        package static func ctl(
            _ epoll: borrowing Kernel.Event.Poll,
            op: Operation,
            fd: borrowing Kernel.Descriptor,
            event: Event? = nil
        ) throws(Kernel.Event.Poll.Error) {
            let result: Int32
            if var cEvent = event?.cValue {
                result = epoll_ctl(epoll.descriptor._rawValue, op.rawValue, fd._rawValue, &cEvent)
            } else {
                result = epoll_ctl(epoll.descriptor._rawValue, op.rawValue, fd._rawValue, nil)
            }
            guard result == 0 else {
                throw .ctl(.posix(errno))
            }
        }

        /// Waits for events (millisecond timeout, internal).
        internal static func wait(
            _ epoll: borrowing Kernel.Event.Poll,
            events: inout [Event],
            timeout: Int32
        ) throws(Kernel.Event.Poll.Error) -> Int {
            guard !events.isEmpty else { return 0 }

            let count = events.count
            let outcome: Result<Int, Error> = withUnsafeTemporaryAllocation(
                of: epoll_event.self,
                capacity: count
            ) { buffer in
                let baseAddress = unsafe buffer.baseAddress!
                let result = unsafe epoll_wait(epoll.descriptor._rawValue, baseAddress, Int32(count), timeout)
                guard result >= 0 else {
                    let code = Kernel.Error.Code.posix(errno)
                    if code.posix == EINTR {
                        return .failure(.interrupted)
                    }
                    return .failure(.wait(code))
                }

                for i in 0..<Int(result) {
                    events[i] = Event(unsafe buffer[i])
                }
                return .success(Int(result))
            }
            return try outcome.get()
        }

        /// Waits for events with a Duration timeout.
        package static func wait(
            _ epoll: borrowing Kernel.Event.Poll,
            events: inout [Event],
            timeout: Duration?
        ) throws(Kernel.Event.Poll.Error) -> Int {
            let ms = Kernel.Time.milliseconds(from: timeout)
            return try wait(epoll, events: &events, timeout: ms)
        }
    }

#endif
