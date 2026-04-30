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

    public import Kernel_Event_Primitives
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.Event.Poll {
        /// An epoll event describing readiness conditions and associated data.
        ///
        /// Layout-compatible with `struct epoll_event`. An
        /// `UnsafeMutablePointer<Event>` may be passed directly to kernel
        /// interfaces that expect `struct epoll_event *`.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Register interest
        /// let event = Kernel.Event.Poll.Event(
        ///     events: [.in, .et],
        ///     data: .init(connectionId)
        /// )
        /// try Kernel.Event.Poll.control(
        ///     epfd,
        ///     operation: .add,
        ///     descriptor: socketFd,
        ///     event: event
        /// )
        ///
        /// // Process returned events
        /// for event in readyEvents {
        ///     if event.events.contains(.in) {
        ///         // Data available for reading
        ///     }
        /// }
        /// ```
        public struct Event: @unchecked Sendable {
            /// The underlying C struct.
            internal var cValue: epoll_event

            /// Creates an epoll event.
            ///
            /// - Parameters:
            ///   - events: The event flags to monitor.
            ///   - data: Data to associate with the file descriptor.
            public init(events: Events = [], data: Kernel.Event.Poll.Data = .zero) {
                self.cValue = epoll_event()
                self.cValue.events = events.rawValue
                self.cValue.data.u64 = data.rawValue
            }
        }
    }

    // MARK: - Accessors

    extension Kernel.Event.Poll.Event {
        /// The event flags that occurred or are being monitored.
        public var events: Kernel.Event.Poll.Events {
            get { Kernel.Event.Poll.Events(rawValue: cValue.events) }
            set { cValue.events = newValue.rawValue }
        }

        /// Data associated with the file descriptor.
        public var data: Kernel.Event.Poll.Data {
            get { Kernel.Event.Poll.Data(__unchecked: (), cValue.data.u64) }
            set { cValue.data.u64 = newValue.rawValue }
        }
    }

    // MARK: - C Conversion

    extension Kernel.Event.Poll.Event {
        /// Creates an epoll event from the C struct.
        internal init(_ cEvent: epoll_event) {
            self.cValue = cEvent
        }
    }

    // MARK: - Equatable, Hashable

    extension Kernel.Event.Poll.Event: Equatable {
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.cValue.events == rhs.cValue.events && lhs.cValue.data.u64 == rhs.cValue.data.u64
        }
    }

    extension Kernel.Event.Poll.Event: Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(cValue.events)
            hasher.combine(cValue.data.u64)
        }
    }

#endif
