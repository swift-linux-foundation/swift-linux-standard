#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Mmap {

        public enum Offset {

            public static let sqRing: Int64 = 0

            public static let cqRing: Int64 = 0x8000000

            public static let sqes: Int64 = 0x1000_0000

            public static let providedBufferRing: Int64 = 0x8000_0000

            public static let providedBufferShift: Int64 = 16

            public static let mask: Int64 = 0xF800_0000
        }
    }

#endif
