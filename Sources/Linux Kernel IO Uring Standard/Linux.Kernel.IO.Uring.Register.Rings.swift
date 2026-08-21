#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Rings {

            public static let enable = Opcode(rawValue: 12)

            public static var descriptor: Descriptor.Type { Descriptor.self }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static var rings: ISO_9945.Kernel.IO.Uring.Register.Rings.Type {
            ISO_9945.Kernel.IO.Uring.Register.Rings.self
        }
    }

#endif
