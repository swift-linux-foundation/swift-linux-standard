#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Buffers {

            public static let register = Opcode(rawValue: 0)

            public static let unregister = Opcode(rawValue: 1)

            public static let register2 = Opcode(rawValue: 15)

            public static let update = Opcode(rawValue: 16)

            public static let clone = Opcode(rawValue: 30)

            public static var provided: Provided.Type { Provided.self }

            public static let sourceRegistered: UInt32 = 1
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var buffers: ISO_9945.Kernel.IO.Uring.Register.Buffers.Type {
            ISO_9945.Kernel.IO.Uring.Register.Buffers.self
        }
    }

#endif
