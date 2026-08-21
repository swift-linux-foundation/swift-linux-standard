#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    @_spi(Syscall) public import Linux_Kernel_Event_Standard

    extension ISO_9945.Kernel.IO.Uring.Wakeup {

        public struct Result: ~Copyable {

            public let signal: @Sendable () -> Void

            private var _eventfd: Linux.Kernel.Event.Descriptor?

            init(
                signal: @escaping @Sendable () -> Void,
                eventfd: consuming Linux.Kernel.Event.Descriptor
            ) {
                self.signal = signal
                self._eventfd = consume eventfd
            }

            public consuming func eventfd() -> Linux.Kernel.Event.Descriptor {
                _eventfd.take()!
            }
        }
    }

#endif
