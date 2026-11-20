#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Write {
        }
    }

    extension Linux.Kernel.IO.Uring.Write {
        public static let standard = Linux.Kernel.IO.Uring.Opcode(rawValue: 23)

        public static var vectored: Vectored.Type { Vectored.self }

        public static let fixed = Linux.Kernel.IO.Uring.Opcode(rawValue: 5)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var write: Linux.Kernel.IO.Uring.Write.Type {
            Linux.Kernel.IO.Uring.Write.self
        }
    }

#endif
