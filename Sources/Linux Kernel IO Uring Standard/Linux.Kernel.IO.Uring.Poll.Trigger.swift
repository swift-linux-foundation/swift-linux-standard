#if os(Linux)

    public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    private let _IORING_POLL_ADD_LEVEL: UInt32 = 1 << 3

    extension ISO_9945.Kernel.IO.Uring.Poll {

        public enum Trigger: Sendable, Hashable {

            case edge

            case level
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Poll.Trigger {

        @usableFromInline
        var pollBits: UInt32 {
            switch self {
            case .edge: 0
            case .level: _IORING_POLL_ADD_LEVEL
            }
        }
    }

#endif
