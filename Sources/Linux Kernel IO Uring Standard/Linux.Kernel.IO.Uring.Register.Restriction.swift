#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Restriction {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Restriction {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 11)
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var restriction: Linux.Kernel.IO.Uring.Register.Restriction.Type {
            Linux.Kernel.IO.Uring.Register.Restriction.self
        }
    }

#endif
