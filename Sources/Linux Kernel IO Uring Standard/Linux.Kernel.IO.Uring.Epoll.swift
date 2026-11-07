#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Epoll {

            public static let ctl = Opcode(rawValue: 29)

            public static let wait = Opcode(rawValue: 59)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var epoll: ISO_9945.Kernel.IO.Uring.Epoll.Type {
            ISO_9945.Kernel.IO.Uring.Epoll.self
        }
    }

#endif
