#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Restriction {

        public enum Kind: UInt16, Sendable {

            case registerOperation = 0

            case entryOperation = 1

            case entryFlagsAllowed = 2

            case entryFlagsRequired = 3
        }
    }

#endif
