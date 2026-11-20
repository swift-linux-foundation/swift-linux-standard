#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Opcode {
        public struct Ring {
        }

        public static var ring: Ring.Type { Ring.self }
    }

    extension Linux.Kernel.IO.Uring.Opcode.Ring {
        public static let msg = Linux.Kernel.IO.Uring.Opcode(rawValue: 40)

        public static let cmd = Linux.Kernel.IO.Uring.Opcode(rawValue: 46)

        public static let cmd128 = Linux.Kernel.IO.Uring.Opcode(rawValue: 64)
    }

#endif
