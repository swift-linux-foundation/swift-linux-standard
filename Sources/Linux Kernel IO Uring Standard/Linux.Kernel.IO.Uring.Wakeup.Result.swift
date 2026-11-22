#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    @_spi(Syscall) import ISO_9945_Core
    @_spi(Syscall) public import Linux_Kernel_Event_Standard

    extension Linux.Kernel.IO.Uring.Wakeup {

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
                guard let descriptor = _eventfd.take() else {
                    preconditionFailure("The eventfd is present until the result is consumed")
                }
                return descriptor
            }
        }
    }

#endif
