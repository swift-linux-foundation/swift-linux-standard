#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Send {
        public struct Zero {
        }
    }

    extension Linux.Kernel.IO.Uring.Send.Zero {
        public static let copy = Linux.Kernel.IO.Uring.Opcode(rawValue: 47)

        public static let msg = Linux.Kernel.IO.Uring.Opcode(rawValue: 48)
    }

#endif
