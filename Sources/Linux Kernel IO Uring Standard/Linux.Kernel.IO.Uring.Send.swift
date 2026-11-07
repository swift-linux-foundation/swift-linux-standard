#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Send {

            public static let standard = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 26)

            public static let message = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 9)

            public static var zero: Zero.Type { Zero.self }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var send: ISO_9945.Kernel.IO.Uring.Send.Type {
            ISO_9945.Kernel.IO.Uring.Send.self
        }
    }

#endif
