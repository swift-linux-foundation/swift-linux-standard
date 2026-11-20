#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct File {
        }
    }

    extension Linux.Kernel.IO.Uring.File {
        public static let openat = Linux.Kernel.IO.Uring.Opcode(rawValue: 18)

        public static let openat2 = Linux.Kernel.IO.Uring.Opcode(rawValue: 28)

        public static let statx = Linux.Kernel.IO.Uring.Opcode(rawValue: 21)

        public static let fallocate = Linux.Kernel.IO.Uring.Opcode(rawValue: 17)

        public static let fadvise = Linux.Kernel.IO.Uring.Opcode(rawValue: 24)

        public static let ftruncate = Linux.Kernel.IO.Uring.Opcode(rawValue: 55)

        public static let renameat = Linux.Kernel.IO.Uring.Opcode(rawValue: 35)

        public static let unlinkat = Linux.Kernel.IO.Uring.Opcode(rawValue: 36)

        public static let mkdirat = Linux.Kernel.IO.Uring.Opcode(rawValue: 37)

        public static let symlinkat = Linux.Kernel.IO.Uring.Opcode(rawValue: 38)

        public static let linkat = Linux.Kernel.IO.Uring.Opcode(rawValue: 39)

        public static let update = Linux.Kernel.IO.Uring.Opcode(rawValue: 20)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var file: Linux.Kernel.IO.Uring.File.Type {
            Linux.Kernel.IO.Uring.File.self
        }
    }

#endif
