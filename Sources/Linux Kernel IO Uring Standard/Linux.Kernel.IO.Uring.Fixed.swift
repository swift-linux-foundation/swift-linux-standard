#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Fixed {

            public static let install = Opcode(rawValue: 54)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var fixed: ISO_9945.Kernel.IO.Uring.Fixed.Type {
            ISO_9945.Kernel.IO.Uring.Fixed.self
        }
    }

#endif
