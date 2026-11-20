#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Sync {
        public struct File {
        }
    }

    extension Linux.Kernel.IO.Uring.Sync.File {
        public static let standard = Linux.Kernel.IO.Uring.Opcode(rawValue: 3)

        public static let range = Linux.Kernel.IO.Uring.Opcode(rawValue: 8)
    }

#endif
