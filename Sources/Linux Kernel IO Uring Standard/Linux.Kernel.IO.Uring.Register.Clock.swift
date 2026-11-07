#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Clock {

            public static let register = Opcode(rawValue: 29)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var clock: ISO_9945.Kernel.IO.Uring.Register.Clock.Type {
            ISO_9945.Kernel.IO.Uring.Register.Clock.self
        }
    }

#endif
