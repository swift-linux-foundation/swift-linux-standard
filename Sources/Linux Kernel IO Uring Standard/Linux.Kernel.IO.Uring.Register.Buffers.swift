#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {
        public struct Buffers {
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Buffers {
        public static let register = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 0)

        public static let unregister = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 1)

        public static let register2 = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 15)

        public static let update = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 16)

        public static let clone = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 30)

        public static var provided: Provided.Type { Provided.self }

        public static let sourceRegistered: UInt32 = 1
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {
        public static var buffers: ISO_9945.Kernel.IO.Uring.Register.Buffers.Type {
            ISO_9945.Kernel.IO.Uring.Register.Buffers.self
        }
    }

#endif
