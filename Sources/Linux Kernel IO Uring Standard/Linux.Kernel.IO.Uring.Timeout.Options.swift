#if os(Linux)

    public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    private let _IORING_TIMEOUT_ETIME_SUCCESS: UInt32 = 1 << 5

    private let _IORING_TIMEOUT_MULTISHOT: UInt32 = 1 << 6

    extension ISO_9945.Kernel.IO.Uring.Timeout {
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Timeout.Options {
        public static let absolute = ISO_9945.Kernel.IO.Uring.Timeout.Options(rawValue: UInt32(IORING_TIMEOUT_ABS))

        public static let multishot = ISO_9945.Kernel.IO.Uring.Timeout.Options(rawValue: _IORING_TIMEOUT_MULTISHOT)

        public static let update = ISO_9945.Kernel.IO.Uring.Timeout.Options(rawValue: UInt32(IORING_TIMEOUT_UPDATE))

        public static let expirySuccess = ISO_9945.Kernel.IO.Uring.Timeout.Options(rawValue: _IORING_TIMEOUT_ETIME_SUCCESS)

        public static let linkUpdate = ISO_9945.Kernel.IO.Uring.Timeout.Options(rawValue: UInt32(IORING_LINK_TIMEOUT_UPDATE))
    }

#endif
