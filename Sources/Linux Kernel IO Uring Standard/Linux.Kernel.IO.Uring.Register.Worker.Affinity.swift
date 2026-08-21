#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register.Worker {

        public struct Affinity {

            public static let register = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 17)

            public static let unregister = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 18)
        }
    }

#endif
