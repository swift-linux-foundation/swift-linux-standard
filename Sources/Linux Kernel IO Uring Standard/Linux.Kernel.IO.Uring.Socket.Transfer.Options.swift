#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Socket.Transfer {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt16

            @inlinable
            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Socket.Transfer.Options {

        public static let pollFirst = Self(rawValue: 1 << 0)

        public static let multishot = Self(rawValue: 1 << 1)

        public static let fixedBuffer = Self(rawValue: 1 << 2)

        public static let reportUsage = Self(rawValue: 1 << 3)

        public static let bundle = Self(rawValue: 1 << 4)
    }

#endif
