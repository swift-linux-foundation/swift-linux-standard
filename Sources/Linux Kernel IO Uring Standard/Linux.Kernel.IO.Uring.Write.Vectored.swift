#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Write {
        public struct Vectored {
        }
    }

    extension Linux.Kernel.IO.Uring.Write.Vectored {
        public static let standard = Linux.Kernel.IO.Uring.Opcode(rawValue: 2)

        public static let fixed = Linux.Kernel.IO.Uring.Opcode(rawValue: 61)
    }

#endif
