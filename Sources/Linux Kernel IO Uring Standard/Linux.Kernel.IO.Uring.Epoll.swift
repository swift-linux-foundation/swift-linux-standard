#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Epoll {
        }
    }

    extension Linux.Kernel.IO.Uring.Epoll {
        public static let ctl = Linux.Kernel.IO.Uring.Opcode(rawValue: 29)

        public static let wait = Linux.Kernel.IO.Uring.Opcode(rawValue: 59)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var epoll: Linux.Kernel.IO.Uring.Epoll.Type {
            Linux.Kernel.IO.Uring.Epoll.self
        }
    }

#endif
