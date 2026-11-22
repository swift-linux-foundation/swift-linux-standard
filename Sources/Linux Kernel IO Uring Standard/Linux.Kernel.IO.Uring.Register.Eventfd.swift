#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Eventfd {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Eventfd {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 4)

        public static let unregister = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 5)

        public static let async = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 7)
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var eventfd: Linux.Kernel.IO.Uring.Register.Eventfd.Type {
            Linux.Kernel.IO.Uring.Register.Eventfd.self
        }
    }

#endif
