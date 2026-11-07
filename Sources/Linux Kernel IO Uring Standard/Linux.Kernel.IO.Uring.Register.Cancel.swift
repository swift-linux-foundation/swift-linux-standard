#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Cancel {

            public static let synchronous = Opcode(rawValue: 24)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var cancel: ISO_9945.Kernel.IO.Uring.Register.Cancel.Type {
            ISO_9945.Kernel.IO.Uring.Register.Cancel.self
        }
    }

#endif
