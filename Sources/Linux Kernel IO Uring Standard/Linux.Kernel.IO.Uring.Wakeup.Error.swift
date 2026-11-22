#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    public import Error

    extension Linux.Kernel.IO.Uring.Wakeup {

        public enum Error: Swift::Error, Sendable, Equatable, Hashable {

            case eventfd(Error::Error.Code)

            case register(Error::Error.Code)
        }
    }

#endif
