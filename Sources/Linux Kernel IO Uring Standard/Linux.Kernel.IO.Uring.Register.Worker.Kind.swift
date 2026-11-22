#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register.Worker {

        public enum Kind: UInt32, Sendable {

            case bound = 0

            case unbound = 1
        }
    }

#endif
