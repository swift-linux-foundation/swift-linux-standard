#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Fixed {
        }
    }

    extension Linux.Kernel.IO.Uring.Fixed {
        public static let install = Linux.Kernel.IO.Uring.Opcode(rawValue: 54)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var fixed: Linux.Kernel.IO.Uring.Fixed.Type {
            Linux.Kernel.IO.Uring.Fixed.self
        }
    }

#endif
