#if os(Linux)

    public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.IO.Uring {

        public enum Clock: Sendable, Hashable {

            case monotonic

            case boottime

            case realtime
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Clock {

        @usableFromInline
        var timeoutBits: UInt32 {
            switch self {
            case .monotonic: 0
            case .boottime: UInt32(IORING_TIMEOUT_BOOTTIME)
            case .realtime: UInt32(IORING_TIMEOUT_REALTIME)
            }
        }
    }

#endif
