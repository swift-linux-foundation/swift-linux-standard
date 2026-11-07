#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct File {

            public static let openat = Opcode(rawValue: 18)

            public static let openat2 = Opcode(rawValue: 28)

            public static let statx = Opcode(rawValue: 21)

            public static let fallocate = Opcode(rawValue: 17)

            public static let fadvise = Opcode(rawValue: 24)

            public static let ftruncate = Opcode(rawValue: 55)

            public static let renameat = Opcode(rawValue: 35)

            public static let unlinkat = Opcode(rawValue: 36)

            public static let mkdirat = Opcode(rawValue: 37)

            public static let symlinkat = Opcode(rawValue: 38)

            public static let linkat = Opcode(rawValue: 39)

            public static let update = Opcode(rawValue: 20)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var file: ISO_9945.Kernel.IO.Uring.File.Type {
            ISO_9945.Kernel.IO.Uring.File.self
        }
    }

#endif
