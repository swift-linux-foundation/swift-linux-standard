#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register.Buffers {

        public struct Provided {

            public static let register = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 22)

            public static let unregister = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 23)

            public static let status = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 26)
        }
    }

#endif
