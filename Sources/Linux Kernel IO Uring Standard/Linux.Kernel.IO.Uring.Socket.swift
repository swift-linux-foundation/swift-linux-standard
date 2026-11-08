#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {
        public struct Socket {
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Socket {
        public static let accept = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 13)

        public static let connect = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 16)

        public static let send = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 26)

        public static let receive = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 27)

        public static var message: Message.Type { Message.self }

        public static let shutdown = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 34)

        public static let create = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 45)

        public static let bind = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 56)

        public static let listen = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 57)

        public static let receiveZeroCopy = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 58)
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        public static var socket: ISO_9945.Kernel.IO.Uring.Socket.Type {
            ISO_9945.Kernel.IO.Uring.Socket.self
        }
    }

#endif
