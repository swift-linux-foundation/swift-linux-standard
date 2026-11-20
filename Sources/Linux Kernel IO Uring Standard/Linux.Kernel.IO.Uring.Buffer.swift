#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public enum Buffer {
        }
    }

    extension Linux.Kernel.IO.Uring.Buffer {
        public static let provide = Linux.Kernel.IO.Uring.Opcode(rawValue: 31)

        public static let remove = Linux.Kernel.IO.Uring.Opcode(rawValue: 32)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var buffer: Linux.Kernel.IO.Uring.Buffer.Type {
            Linux.Kernel.IO.Uring.Buffer.self
        }
    }

#endif
