#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Socket {

            public static let accept = Opcode(rawValue: 13)

            public static let connect = Opcode(rawValue: 16)

            public static let send = Opcode(rawValue: 26)

            public static let receive = Opcode(rawValue: 27)

            public static var message: Message.Type { Message.self }

            public static let shutdown = Opcode(rawValue: 34)

            public static let create = Opcode(rawValue: 45)

            public static let bind = Opcode(rawValue: 56)

            public static let listen = Opcode(rawValue: 57)

            public static let receiveZeroCopy = Opcode(rawValue: 58)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var socket: ISO_9945.Kernel.IO.Uring.Socket.Type {
            ISO_9945.Kernel.IO.Uring.Socket.self
        }
    }

#endif
