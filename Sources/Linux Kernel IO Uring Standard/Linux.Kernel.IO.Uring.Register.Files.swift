#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Files {

            public static let register = Opcode(rawValue: 2)

            public static let unregister = Opcode(rawValue: 3)

            public static let update = Opcode(rawValue: 6)

            public static let register2 = Opcode(rawValue: 13)

            public static let update2 = Opcode(rawValue: 14)

            public static var alloc: Alloc.Type { Alloc.self }

            public static let skip: Int32 = -2

            public static let indexAlloc: UInt32 = 0xFFFF_FFFF
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var files: ISO_9945.Kernel.IO.Uring.Register.Files.Type {
            ISO_9945.Kernel.IO.Uring.Register.Files.self
        }
    }

#endif
