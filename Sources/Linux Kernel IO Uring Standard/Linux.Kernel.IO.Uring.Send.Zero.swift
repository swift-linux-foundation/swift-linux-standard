#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Send {

        public struct Zero {

            public static let copy = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 47)

            public static let msg = ISO_9945.Kernel.IO.Uring.Opcode(rawValue: 48)
        }
    }

#endif
