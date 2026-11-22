#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct NAPI {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.NAPI {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 27)

        public static let unregister = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 28)
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var napi: Linux.Kernel.IO.Uring.Register.NAPI.Type {
            Linux.Kernel.IO.Uring.Register.NAPI.self
        }
    }

#endif
