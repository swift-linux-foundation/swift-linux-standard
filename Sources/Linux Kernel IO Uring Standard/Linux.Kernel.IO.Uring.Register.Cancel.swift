#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Cancel {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Cancel {
        public static let synchronous = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 24)
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var cancel: Linux.Kernel.IO.Uring.Register.Cancel.Type {
            Linux.Kernel.IO.Uring.Register.Cancel.self
        }
    }

#endif
