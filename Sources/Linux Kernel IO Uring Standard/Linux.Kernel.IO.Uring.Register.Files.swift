#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Files {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Files {
        public static let register = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 2)

        public static let unregister = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 3)

        public static let update = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 6)

        public static let register2 = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 13)

        public static let update2 = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 14)

        public static var alloc: Alloc.Type { Alloc.self }

        public static let skip: Int32 = -2

        public static let indexAlloc: UInt32 = 0xFFFF_FFFF
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var files: Linux.Kernel.IO.Uring.Register.Files.Type {
            Linux.Kernel.IO.Uring.Register.Files.self
        }
    }

#endif
