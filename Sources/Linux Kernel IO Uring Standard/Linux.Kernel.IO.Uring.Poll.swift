#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Poll {
        }
    }

    extension Linux.Kernel.IO.Uring.Poll {
        public static let add = Linux.Kernel.IO.Uring.Opcode(rawValue: 6)

        public static let remove = Linux.Kernel.IO.Uring.Opcode(rawValue: 7)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var poll: Linux.Kernel.IO.Uring.Poll.Type {
            Linux.Kernel.IO.Uring.Poll.self
        }
    }

#endif
