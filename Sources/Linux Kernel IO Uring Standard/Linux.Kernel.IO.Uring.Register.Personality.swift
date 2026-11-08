#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {
        public struct Personality {
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Personality {
        public static let register = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 9)

        public static let unregister = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 10)
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {
        public static var personality: ISO_9945.Kernel.IO.Uring.Register.Personality.Type {
            ISO_9945.Kernel.IO.Uring.Register.Personality.self
        }
    }

#endif
