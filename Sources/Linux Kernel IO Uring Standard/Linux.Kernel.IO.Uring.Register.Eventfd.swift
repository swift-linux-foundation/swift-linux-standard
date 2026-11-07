#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Eventfd {

            public static let register = Opcode(rawValue: 4)

            public static let unregister = Opcode(rawValue: 5)

            public static let async = Opcode(rawValue: 7)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var eventfd: ISO_9945.Kernel.IO.Uring.Register.Eventfd.Type {
            ISO_9945.Kernel.IO.Uring.Register.Eventfd.self
        }
    }

#endif
