#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Read {

            public static let standard = Opcode(rawValue: 22)

            public static var vectored: Vectored.Type { Vectored.self }

            public static let fixed = Opcode(rawValue: 4)

            public static let multishot = Opcode(rawValue: 49)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var read: ISO_9945.Kernel.IO.Uring.Read.Type {
            ISO_9945.Kernel.IO.Uring.Read.self
        }
    }

#endif
