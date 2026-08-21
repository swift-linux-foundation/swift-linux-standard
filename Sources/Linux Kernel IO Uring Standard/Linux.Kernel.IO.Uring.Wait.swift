#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Wait {

            public static let id = Opcode(rawValue: 50)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var wait: ISO_9945.Kernel.IO.Uring.Wait.Type {
            ISO_9945.Kernel.IO.Uring.Wait.self
        }
    }

#endif
