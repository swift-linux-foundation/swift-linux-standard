#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Clock {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Clock {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 29)
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var clock: Linux.Kernel.IO.Uring.Register.Clock.Type {
            Linux.Kernel.IO.Uring.Register.Clock.self
        }
    }

#endif
