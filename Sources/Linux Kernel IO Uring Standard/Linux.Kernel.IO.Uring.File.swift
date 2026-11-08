#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {
        public struct File {
        }
    }

    extension ISO_9945.Kernel.IO.Uring.File {
        public static let openat = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 18)

        public static let openat2 = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 28)

        public static let statx = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 21)

        public static let fallocate = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 17)

        public static let fadvise = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 24)

        public static let ftruncate = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 55)

        public static let renameat = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 35)

        public static let unlinkat = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 36)

        public static let mkdirat = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 37)

        public static let symlinkat = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 38)

        public static let linkat = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 39)

        public static let update = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 20)
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        public static var file: ISO_9945.Kernel.IO.Uring.File.Type {
            ISO_9945.Kernel.IO.Uring.File.self
        }
    }

#endif
