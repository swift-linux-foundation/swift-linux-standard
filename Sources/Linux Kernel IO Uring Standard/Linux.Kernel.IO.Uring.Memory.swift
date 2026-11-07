#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Memory {

            public static let madvise = Opcode(rawValue: 25)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static var memory: ISO_9945.Kernel.IO.Uring.Memory.Type {
            ISO_9945.Kernel.IO.Uring.Memory.self
        }
    }

#endif
