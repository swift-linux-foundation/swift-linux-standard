#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Accept {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Accept.Options {

        public static let multishot = Self(rawValue: 1 << 0)

        public static let dontWait = Self(rawValue: 1 << 1)

        public static let pollFirst = Self(rawValue: 1 << 2)
    }

#endif
