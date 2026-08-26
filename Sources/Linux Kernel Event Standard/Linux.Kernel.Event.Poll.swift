#if os(Linux)

    public import ISO_9945_Kernel_Time
    @_spi(Syscall) public import ISO_9945_Core
    public import Linux_Standard_Core
    public import Error

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.Event {

        @safe
        public struct Poll: ~Copyable, Sendable {

            @_spi(Syscall)
            public let descriptor: ISO_9945.Kernel.Descriptor

            public init(flags: Create.Flags = .cloexec) throws(Error) {
                self.descriptor = try Self.create(flags: flags)
            }
        }
    }

    extension Linux.Kernel.Event.Poll {

        public func add(
            fd: borrowing ISO_9945.Kernel.Descriptor,
            event: Event
        ) throws(Error) {
            try Self.ctl(self, op: .add, fd: fd, event: event)
        }

        public func modify(
            fd: borrowing ISO_9945.Kernel.Descriptor,
            event: Event
        ) throws(Error) {
            try Self.ctl(self, op: .modify, fd: fd, event: event)
        }

        public func remove(
            fd: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) {
            try Self.ctl(self, op: .delete, fd: fd)
        }

        public func poll(
            events: inout [Event],
            timeout: Duration?
        ) throws(Error) -> Int {
            try Self.wait(self, events: &events, timeout: timeout)
        }

        public func wakeup(
            eventfd: borrowing Linux.Kernel.Event.Descriptor
        ) throws(Error) -> @Sendable () -> Void {
            let wakeupEvent = Linux.Kernel.Event.Poll.Event(events: [.in, .et])
            try self.add(fd: eventfd.descriptor, event: wakeupEvent)
            let rawEfd = eventfd.descriptor._rawValue
            return {
                Linux.Kernel.Event.Descriptor.signal(rawDescriptor: rawEfd)
            }
        }
    }

    extension Linux.Kernel.Event.Poll {

        package static func create(
            flags: Create.Flags = .cloexec
        ) throws(Linux.Kernel.Event.Poll.Error) -> ISO_9945.Kernel.Descriptor {
            let epfd = epoll_create1(flags.rawValue)
            guard epfd >= 0 else {
                throw .create(.posix(errno))
            }
            return ISO_9945.Kernel.Descriptor(_rawValue: epfd)
        }

        package static func ctl(
            _ epoll: borrowing Linux.Kernel.Event.Poll,
            op: Operation,
            fd: borrowing ISO_9945.Kernel.Descriptor,
            event: Event? = nil
        ) throws(Linux.Kernel.Event.Poll.Error) {
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

        internal static func wait(
            _ epoll: borrowing Linux.Kernel.Event.Poll,
            events: inout [Event],
            timeout: Int32
        ) throws(Linux.Kernel.Event.Poll.Error) -> Int {
            guard !events.isEmpty else { return 0 }

            let count = events.count
            let outcome: Result<Int, Linux.Kernel.Event.Poll.Error> = withUnsafeTemporaryAllocation(
                of: epoll_event.self,
                capacity: count
            ) { buffer in
                let baseAddress = unsafe buffer.baseAddress!
                let result = unsafe epoll_wait(
                    epoll.descriptor._rawValue,
                    baseAddress,
                    Int32(count),
                    timeout
                )
                guard result >= 0 else {
                    let code = Error.Error.Code.posix(errno)
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

        package static func wait(
            _ epoll: borrowing Linux.Kernel.Event.Poll,
            events: inout [Event],
            timeout: Duration?
        ) throws(Linux.Kernel.Event.Poll.Error) -> Int {
            let ms = ISO_9945.Kernel.Time.milliseconds(from: timeout)
            return try wait(epoll, events: &events, timeout: ms)
        }
    }

#endif
