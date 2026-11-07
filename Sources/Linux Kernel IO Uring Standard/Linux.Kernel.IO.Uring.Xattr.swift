#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Xattr {

            public static let fset = Opcode(rawValue: 41)

            public static let set = Opcode(rawValue: 42)

            public static let fget = Opcode(rawValue: 43)

            public static let get = Opcode(rawValue: 44)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var xattr: ISO_9945.Kernel.IO.Uring.Xattr.Type {
            ISO_9945.Kernel.IO.Uring.Xattr.self
        }
    }

#endif
