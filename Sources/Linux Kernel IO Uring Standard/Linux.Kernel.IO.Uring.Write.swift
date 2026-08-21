#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Write {

            public static let standard = Opcode(rawValue: 23)

            public static var vectored: Vectored.Type { Vectored.self }

            public static let fixed = Opcode(rawValue: 5)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var write: ISO_9945.Kernel.IO.Uring.Write.Type {
            ISO_9945.Kernel.IO.Uring.Write.self
        }
    }

#endif
