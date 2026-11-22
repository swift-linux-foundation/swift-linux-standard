#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Wait {
        }
    }

    extension Linux.Kernel.IO.Uring.Wait {
        public static let id = Linux.Kernel.IO.Uring.Opcode(rawValue: 50)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var wait: Linux.Kernel.IO.Uring.Wait.Type {
            Linux.Kernel.IO.Uring.Wait.self
        }
    }

#endif
