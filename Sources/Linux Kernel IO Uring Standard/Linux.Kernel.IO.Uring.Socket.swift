#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Socket {
        }
    }

    extension Linux.Kernel.IO.Uring.Socket {
        public static let accept = Linux.Kernel.IO.Uring.Opcode(rawValue: 13)

        public static let connect = Linux.Kernel.IO.Uring.Opcode(rawValue: 16)

        public static let send = Linux.Kernel.IO.Uring.Opcode(rawValue: 26)

        public static let receive = Linux.Kernel.IO.Uring.Opcode(rawValue: 27)

        public static var message: Message.Type { Message.self }

        public static let shutdown = Linux.Kernel.IO.Uring.Opcode(rawValue: 34)

        public static let create = Linux.Kernel.IO.Uring.Opcode(rawValue: 45)

        public static let bind = Linux.Kernel.IO.Uring.Opcode(rawValue: 56)

        public static let listen = Linux.Kernel.IO.Uring.Opcode(rawValue: 57)

        public static let receiveZeroCopy = Linux.Kernel.IO.Uring.Opcode(rawValue: 58)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var socket: Linux.Kernel.IO.Uring.Socket.Type {
            Linux.Kernel.IO.Uring.Socket.self
        }
    }

#endif
