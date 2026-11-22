#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register.Rings {
        public struct Descriptor {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Rings.Descriptor {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 20)

        public static let unregister = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 21)
    }

#endif
