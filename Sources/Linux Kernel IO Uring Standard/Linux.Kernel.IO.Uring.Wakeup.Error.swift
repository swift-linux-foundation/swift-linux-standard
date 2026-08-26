#if os(Linux)

    public import ISO_9945_Core
    public import Error

    extension ISO_9945.Kernel.IO.Uring.Wakeup {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case eventfd(Error.Error.Code)

            case register(Error.Error.Code)
        }
    }

#endif
