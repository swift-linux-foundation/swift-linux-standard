#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {
        public struct Xattr {
        }
    }

    extension Linux.Kernel.IO.Uring.Xattr {
        public static let fset = Linux.Kernel.IO.Uring.Opcode(rawValue: 41)

        public static let set = Linux.Kernel.IO.Uring.Opcode(rawValue: 42)

        public static let fget = Linux.Kernel.IO.Uring.Opcode(rawValue: 43)

        public static let get = Linux.Kernel.IO.Uring.Opcode(rawValue: 44)
    }

    extension Linux.Kernel.IO.Uring.Opcode {
        public static var xattr: Linux.Kernel.IO.Uring.Xattr.Type {
            Linux.Kernel.IO.Uring.Xattr.self
        }
    }

#endif
