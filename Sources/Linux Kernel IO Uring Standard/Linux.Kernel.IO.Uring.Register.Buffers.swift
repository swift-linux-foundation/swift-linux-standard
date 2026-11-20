#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Buffers {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Buffers {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 0)

        public static let unregister = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 1)

        public static let register2 = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 15)

        public static let update = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 16)

        public static let clone = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 30)

        public static var provided: Provided.Type { Provided.self }

        public static let sourceRegistered: UInt32 = 1
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var buffers: Linux.Kernel.IO.Uring.Register.Buffers.Type {
            Linux.Kernel.IO.Uring.Register.Buffers.self
        }
    }

#endif
