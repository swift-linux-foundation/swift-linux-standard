#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Rings {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Rings {
        public static let enable = Linux.Kernel.IO.Uring.Register.Opcode(rawValue: 12)

        public static var descriptor: Descriptor.Type { Descriptor.self }
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static var rings: Linux.Kernel.IO.Uring.Register.Rings.Type {
            Linux.Kernel.IO.Uring.Register.Rings.self
        }
    }

#endif
