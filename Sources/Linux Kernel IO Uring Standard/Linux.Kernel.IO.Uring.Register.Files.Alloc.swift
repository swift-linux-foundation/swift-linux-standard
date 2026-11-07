#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register.Files {

        public struct Alloc {

            public static let range = ISO_9945.Kernel.IO.Uring.Register.Opcode(rawValue: 25)
        }
    }

#endif
