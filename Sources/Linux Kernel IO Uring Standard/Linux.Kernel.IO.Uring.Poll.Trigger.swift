#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    private let _IORING_POLL_ADD_LEVEL: UInt32 = 1 << 3

    extension Linux.Kernel.IO.Uring.Poll {

        public enum Trigger: Sendable, Hashable {

            case edge

            case level
        }
    }

    extension Linux.Kernel.IO.Uring.Poll.Trigger {

        @usableFromInline
        var pollBits: UInt32 {
            switch self {
            case .edge: 0
            case .level: _IORING_POLL_ADD_LEVEL
            }
        }
    }

#endif
