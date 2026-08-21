#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Message {

        public enum Kind: UInt32, Sendable {

            case data = 0

            case sendDescriptor = 1
        }
    }

#endif
