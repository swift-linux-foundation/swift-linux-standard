#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Sync {

        public struct File {

            public static let standard = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 3)

            public static let range = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 8)
        }
    }

#endif
