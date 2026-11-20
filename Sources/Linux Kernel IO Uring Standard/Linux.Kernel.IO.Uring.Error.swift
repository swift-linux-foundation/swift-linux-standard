#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    public import Error

    extension Linux.Kernel.IO.Uring {

        public enum Error: Swift::Error, Sendable, Equatable, Hashable {

            case setup(Error::Error.Code)

            case enter(Error::Error.Code)

            case register(Error::Error.Code)

            case interrupted
        }
    }

    extension Linux.Kernel.IO.Uring.Error: CustomStringConvertible {
        public var description: Swift::String {
            switch self {
            case .setup(let code):
                return "io_uring_setup failed (\(code))"

            case .enter(let code):
                return "io_uring_enter failed (\(code))"

            case .register(let code):
                return "io_uring_register failed (\(code))"

            case .interrupted:
                return "operation interrupted"
            }
        }
    }

#endif
