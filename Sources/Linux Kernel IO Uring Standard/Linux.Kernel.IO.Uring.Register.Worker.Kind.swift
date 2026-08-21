#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register.Worker {

        public enum Kind: UInt32, Sendable {

            case bound = 0

            case unbound = 1
        }
    }

#endif
