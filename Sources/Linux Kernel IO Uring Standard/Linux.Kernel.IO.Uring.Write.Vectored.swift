#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Write {

        public struct Vectored {

            public static let standard = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 2)

            public static let fixed = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 61)
        }
    }

#endif
