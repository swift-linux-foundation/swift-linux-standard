#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Timeout {
        }
    }

    extension Linux.Kernel.IO.Uring.Timeout {
        public static let standard = Linux.Kernel.IO.Uring.Opcode(rawValue: 11)

        public static let remove = Linux.Kernel.IO.Uring.Opcode(rawValue: 12)

        public static let link = Linux.Kernel.IO.Uring.Opcode(rawValue: 15)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var timeout: Linux.Kernel.IO.Uring.Timeout.Type {
            Linux.Kernel.IO.Uring.Timeout.self
        }
    }

#endif
