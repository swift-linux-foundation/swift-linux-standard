#if os(Linux)

    public import Linux_Standard_Core
    public import Error

    extension Linux.Kernel.Event.Poll {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case create(Error.Error.Code)

            case ctl(Error.Error.Code)

            case wait(Error.Error.Code)

            case interrupted
        }
    }

    extension Linux.Kernel.Event.Poll.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let code):
                return "epoll_create1 failed (\(code))"

            case .ctl(let code):
                return "epoll_ctl failed (\(code))"

            case .wait(let code):
                return "epoll_wait failed (\(code))"

            case .interrupted:
                return "operation interrupted"
            }
        }
    }

#endif
