#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Personality {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Personality {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 9)

        public static let unregister = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 10)
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var personality: Linux.Kernel.IO.Uring.Register.Personality.Type {
            Linux.Kernel.IO.Uring.Register.Personality.self
        }
    }

#endif
