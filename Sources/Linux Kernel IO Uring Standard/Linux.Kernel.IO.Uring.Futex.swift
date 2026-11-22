#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Futex {
        }
    }

    extension Linux.Kernel.IO.Uring.Futex {
        public static let wait = Linux.Kernel.IO.Uring.Opcode(rawValue: 51)

        public static let wake = Linux.Kernel.IO.Uring.Opcode(rawValue: 52)

        public static let waitv = Linux.Kernel.IO.Uring.Opcode(rawValue: 53)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var futex: Linux.Kernel.IO.Uring.Futex.Type {
            Linux.Kernel.IO.Uring.Futex.self
        }
    }

#endif
