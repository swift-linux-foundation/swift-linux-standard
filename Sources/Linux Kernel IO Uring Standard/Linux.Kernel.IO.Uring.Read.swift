#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Read {
        }
    }

    extension Linux.Kernel.IO.Uring.Read {
        public static let standard = Linux.Kernel.IO.Uring.Opcode(rawValue: 22)

        public static var vectored: Vectored.Type { Vectored.self }

        public static let fixed = Linux.Kernel.IO.Uring.Opcode(rawValue: 4)

        public static let multishot = Linux.Kernel.IO.Uring.Opcode(rawValue: 49)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var read: Linux.Kernel.IO.Uring.Read.Type {
            Linux.Kernel.IO.Uring.Read.self
        }
    }

#endif
