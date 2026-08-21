#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry.Options {

        public static let buffer = Self(rawValue: 1 << 0)

        public static let more = Self(rawValue: 1 << 1)

        public static let sockNonempty = Self(rawValue: 1 << 2)

        public static let notif = Self(rawValue: 1 << 3)

        public static let bufferMore = Self(rawValue: 1 << 4)
    }

#endif
