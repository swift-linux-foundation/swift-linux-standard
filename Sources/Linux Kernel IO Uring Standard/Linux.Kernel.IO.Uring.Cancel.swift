#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Cancel {

            public static let async = Opcode(rawValue: 14)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var cancel: ISO_9945.Kernel.IO.Uring.Cancel.Type {
            ISO_9945.Kernel.IO.Uring.Cancel.self
        }
    }

#endif
