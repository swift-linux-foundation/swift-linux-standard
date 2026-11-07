#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public struct Ring {

            public static let msg = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 40)

            public static let cmd = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 46)

            public static let cmd128 = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 64)
        }

        public static var ring: Ring.Type { Ring.self }
    }

#endif
