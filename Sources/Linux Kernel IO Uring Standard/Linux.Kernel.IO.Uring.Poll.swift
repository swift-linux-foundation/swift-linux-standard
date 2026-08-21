#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Poll {

            public static let add = Opcode(rawValue: 6)

            public static let remove = Opcode(rawValue: 7)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var poll: ISO_9945.Kernel.IO.Uring.Poll.Type {
            ISO_9945.Kernel.IO.Uring.Poll.self
        }
    }

#endif
