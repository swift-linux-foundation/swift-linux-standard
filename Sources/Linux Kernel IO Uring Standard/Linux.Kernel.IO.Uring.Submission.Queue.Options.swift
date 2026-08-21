#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Submission.Queue {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Options {

        public static let needWakeup = Self(rawValue: 1 << 0)

        public static let completionOverflow = Self(rawValue: 1 << 1)

        public static let taskrun = Self(rawValue: 1 << 2)
    }

#endif
