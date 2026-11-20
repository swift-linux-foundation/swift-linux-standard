#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Message {

        public enum Kind: UInt32, Sendable {

            case data = 0

            case sendDescriptor = 1
        }
    }

#endif
