#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register.Rings {

        public struct Descriptor {

            public static let register = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 20)

            public static let unregister = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 21)
        }
    }

#endif
