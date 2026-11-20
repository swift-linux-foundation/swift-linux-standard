#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Send {
        }
    }

    extension Linux.Kernel.IO.Uring.Send {
        public static let standard = Linux.Kernel.IO.Uring.Opcode(rawValue: 26)

        public static let message = Linux.Kernel.IO.Uring.Opcode(rawValue: 9)

        public static var zero: Zero.Type { Zero.self }
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var send: Linux.Kernel.IO.Uring.Send.Type {
            Linux.Kernel.IO.Uring.Send.self
        }
    }

#endif
