#if os(Linux)

    public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    private let _IORING_POLL_ADD_LEVEL: UInt32 = 1 << 3

    extension ISO_9945.Kernel.IO.Uring.Poll {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let level = Options(rawValue: _IORING_POLL_ADD_LEVEL)

            public static let multishot = Options(rawValue: UInt32(IORING_POLL_ADD_MULTI))

            public static let updateEvents = Options(rawValue: UInt32(IORING_POLL_UPDATE_EVENTS))

            public static let updateUserData = Options(
                rawValue: UInt32(IORING_POLL_UPDATE_USER_DATA)
            )
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Poll.Trigger {

        @usableFromInline
        var option: ISO_9945.Kernel.IO.Uring.Poll.Options {
            switch self {
            case .edge: []
            case .level: .level
            }
        }
    }

#endif
