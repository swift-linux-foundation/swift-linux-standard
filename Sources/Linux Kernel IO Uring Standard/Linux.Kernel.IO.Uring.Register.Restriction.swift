#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Restriction {

            public static let register = Opcode(rawValue: 11)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var restriction: ISO_9945.Kernel.IO.Uring.Register.Restriction.Type {
            ISO_9945.Kernel.IO.Uring.Register.Restriction.self
        }
    }

#endif
