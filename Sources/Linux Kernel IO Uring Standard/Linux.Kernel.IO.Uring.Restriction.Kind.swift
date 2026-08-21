#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Restriction {

        public enum Kind: UInt16, Sendable {

            case registerOperation = 0

            case entryOperation = 1

            case entryFlagsAllowed = 2

            case entryFlagsRequired = 3
        }
    }

#endif
