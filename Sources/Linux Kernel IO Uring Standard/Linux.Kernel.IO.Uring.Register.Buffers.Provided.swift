#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register.Buffers {
        public struct Provided {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Buffers.Provided {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 22)

        public static let unregister = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 23)

        public static let status = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 26)
    }

#endif
