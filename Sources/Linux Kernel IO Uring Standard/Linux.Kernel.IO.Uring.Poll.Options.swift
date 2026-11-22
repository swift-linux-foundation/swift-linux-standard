#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    private let _IORING_POLL_ADD_LEVEL: UInt32 = 1 << 3

    extension Linux.Kernel.IO.Uring.Poll {
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Poll.Options {
        public static let level = Linux.Kernel.IO.Uring.Poll.Options(rawValue: _IORING_POLL_ADD_LEVEL)

        public static let multishot = Linux.Kernel.IO.Uring.Poll.Options(rawValue: UInt32(IORING_POLL_ADD_MULTI))

        public static let updateEvents = Linux.Kernel.IO.Uring.Poll.Options(rawValue: UInt32(IORING_POLL_UPDATE_EVENTS))

        public static let updateUserData = Linux.Kernel.IO.Uring.Poll.Options(
            rawValue: UInt32(IORING_POLL_UPDATE_USER_DATA)
        )
    }

    extension Linux.Kernel.IO.Uring.Poll.Trigger {
        @usableFromInline
        var option: Linux.Kernel.IO.Uring.Poll.Options {
            switch self {
            case .edge: []
            case .level: .level
            }
        }
    }

#endif
