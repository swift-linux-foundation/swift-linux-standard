#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Socket {

        public struct Message {

            public static let send = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 9)

            public static let receive = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 10)
        }
    }

#endif
