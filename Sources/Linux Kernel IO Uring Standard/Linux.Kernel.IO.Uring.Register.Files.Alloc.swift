#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register.Files {
        public struct Alloc {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Files.Alloc {
        public static let range = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 25)
    }

#endif
