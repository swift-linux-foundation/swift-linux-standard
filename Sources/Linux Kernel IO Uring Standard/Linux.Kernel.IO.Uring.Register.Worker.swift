#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Worker {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Worker {
        public static var affinity: Affinity.Type { Affinity.self }

        public static let max = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 19)
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var worker: Linux.Kernel.IO.Uring.Register.Worker.Type {
            Linux.Kernel.IO.Uring.Register.Worker.self
        }
    }

#endif
