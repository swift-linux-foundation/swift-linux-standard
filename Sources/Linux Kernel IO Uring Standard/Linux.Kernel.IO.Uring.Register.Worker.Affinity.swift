#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register.Worker {
        public struct Affinity {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Worker.Affinity {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 17)

        public static let unregister = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 18)
    }

#endif
