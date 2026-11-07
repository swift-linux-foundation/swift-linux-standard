#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Futex {

            public static let wait = Opcode(rawValue: 51)

            public static let wake = Opcode(rawValue: 52)

            public static let waitv = Opcode(rawValue: 53)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var futex: ISO_9945.Kernel.IO.Uring.Futex.Type {
            ISO_9945.Kernel.IO.Uring.Futex.self
        }
    }

#endif
