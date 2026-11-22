#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Memory {
        }
    }

    extension Linux.Kernel.IO.Uring.Memory {
        public static let madvise = Linux.Kernel.IO.Uring.Opcode(rawValue: 25)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var memory: Linux.Kernel.IO.Uring.Memory.Type {
            Linux.Kernel.IO.Uring.Memory.self
        }
    }

#endif
