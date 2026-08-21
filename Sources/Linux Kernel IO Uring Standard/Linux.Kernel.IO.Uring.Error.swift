#if os(Linux)

    public import ISO_9945_Core
    public import Error_Primitives

    extension ISO_9945.Kernel.IO.Uring {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case setup(Error_Primitives.Error.Code)

            case enter(Error_Primitives.Error.Code)

            case register(Error_Primitives.Error.Code)

            case interrupted
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Error: CustomStringConvertible {
        public var description: Swift.String {
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
