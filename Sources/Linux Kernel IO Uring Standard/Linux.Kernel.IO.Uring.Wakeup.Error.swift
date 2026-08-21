#if os(Linux)

    public import ISO_9945_Core
    public import Error_Primitives

    extension ISO_9945.Kernel.IO.Uring.Wakeup {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case eventfd(Error_Primitives.Error.Code)

            case register(Error_Primitives.Error.Code)
        }
    }

#endif
