#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {
        public enum Buffer {
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Buffer {
        public static let provide = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 31)

        public static let remove = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 32)
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        public static var buffer: ISO_9945.Kernel.IO.Uring.Buffer.Type {
            ISO_9945.Kernel.IO.Uring.Buffer.self
        }
    }

#endif
