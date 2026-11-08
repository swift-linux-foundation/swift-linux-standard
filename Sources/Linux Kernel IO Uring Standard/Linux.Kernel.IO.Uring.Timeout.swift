#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {
        public struct Timeout {
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Timeout {
        public static let standard = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 11)

        public static let remove = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 12)

        public static let link = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 15)
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        public static var timeout: ISO_9945.Kernel.IO.Uring.Timeout.Type {
            ISO_9945.Kernel.IO.Uring.Timeout.self
        }
    }

#endif
