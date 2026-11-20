#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Cancel {
        }
    }

    extension Linux.Kernel.IO.Uring.Cancel {
        public static let async = Linux.Kernel.IO.Uring.Opcode(rawValue: 14)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var cancel: Linux.Kernel.IO.Uring.Cancel.Type {
            Linux.Kernel.IO.Uring.Cancel.self
        }
    }

#endif
