#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    private let _IORING_TIMEOUT_ETIME_SUCCESS: UInt32 = 1 << 5

    private let _IORING_TIMEOUT_MULTISHOT: UInt32 = 1 << 6

    extension Linux.Kernel.IO.Uring.Timeout {
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Timeout.Options {
        public static let absolute = Linux.Kernel.IO.Uring.Timeout.Options(rawValue: UInt32(IORING_TIMEOUT_ABS))

        public static let multishot = Linux.Kernel.IO.Uring.Timeout.Options(rawValue: _IORING_TIMEOUT_MULTISHOT)

        public static let update = Linux.Kernel.IO.Uring.Timeout.Options(rawValue: UInt32(IORING_TIMEOUT_UPDATE))

        public static let expirySuccess = Linux.Kernel.IO.Uring.Timeout.Options(rawValue: _IORING_TIMEOUT_ETIME_SUCCESS)

        public static let linkUpdate = Linux.Kernel.IO.Uring.Timeout.Options(rawValue: UInt32(IORING_LINK_TIMEOUT_UPDATE))
    }

#endif
