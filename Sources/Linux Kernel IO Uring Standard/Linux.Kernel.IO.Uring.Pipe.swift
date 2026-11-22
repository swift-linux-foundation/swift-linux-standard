#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Pipe {
        }
    }

    extension Linux.Kernel.IO.Uring.Pipe {
        public static let splice = Linux.Kernel.IO.Uring.Opcode(rawValue: 30)

        public static let tee = Linux.Kernel.IO.Uring.Opcode(rawValue: 33)

        public static let create = Linux.Kernel.IO.Uring.Opcode(rawValue: 62)

        public static let fixedDescriptorIn: UInt32 = 0x8000_0000
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var pipe: Linux.Kernel.IO.Uring.Pipe.Type {
            Linux.Kernel.IO.Uring.Pipe.self
        }
    }

#endif
