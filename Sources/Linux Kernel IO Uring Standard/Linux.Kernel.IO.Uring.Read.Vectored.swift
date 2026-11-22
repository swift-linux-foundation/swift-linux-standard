#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Read {
        public struct Vectored {
        }
    }

    extension Linux.Kernel.IO.Uring.Read.Vectored {
        public static let standard = Linux.Kernel.IO.Uring.Opcode(rawValue: 1)

        public static let fixed = Linux.Kernel.IO.Uring.Opcode(rawValue: 60)
    }

#endif
