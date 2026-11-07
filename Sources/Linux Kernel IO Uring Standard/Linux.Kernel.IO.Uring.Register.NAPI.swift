#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct NAPI {

            public static let register = Opcode(rawValue: 27)

            public static let unregister = Opcode(rawValue: 28)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var napi: ISO_9945.Kernel.IO.Uring.Register.NAPI.Type {
            ISO_9945.Kernel.IO.Uring.Register.NAPI.self
        }
    }

#endif
