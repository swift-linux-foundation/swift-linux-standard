#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Socket {
        public struct Message {
        }
    }

    extension Linux.Kernel.IO.Uring.Socket.Message {
        public static let send = Linux.Kernel.IO.Uring.Opcode(rawValue: 9)

        public static let receive = Linux.Kernel.IO.Uring.Opcode(rawValue: 10)
    }

#endif
