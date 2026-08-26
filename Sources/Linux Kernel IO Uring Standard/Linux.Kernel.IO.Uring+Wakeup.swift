#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import Error
    @_spi(Syscall) public import Linux_Kernel_Event_Standard

    extension ISO_9945.Kernel.IO.Uring {

        public func createWakeup() throws(Wakeup.Error) -> Wakeup.Result {

            let eventfd = try Self.createEventfd()

            do throws(ISO_9945.Kernel.IO.Uring.Error) {
                try self.register(eventfd: eventfd.descriptor)
            } catch {
                throw .register(error.code)
            }

            let rawEfd = eventfd.descriptor._rawValue
            let signal: @Sendable () -> Void = {
                Linux.Kernel.Event.Descriptor.signal(rawDescriptor: rawEfd)
            }

            return Wakeup.Result(
                signal: signal,
                eventfd: consume eventfd
            )
        }

        private static func createEventfd() throws(Wakeup.Error) -> Linux.Kernel.Event.Descriptor {
            do throws(Linux.Kernel.Event.Descriptor.Error) {
                return try Linux.Kernel.Event.Descriptor.create(flags: .cloexec)
            } catch {
                switch error {
                case .create(let code): throw .eventfd(code)

                case .read, .write, .wouldBlock:
                    throw .eventfd(.POSIX.EINVAL)
                }
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Error {

        var code: Error.Error.Code {
            switch self {
            case .setup(let code): code
            case .enter(let code): code
            case .register(let code): code
            case .interrupted: .POSIX.EINTR
            }
        }
    }

#endif
