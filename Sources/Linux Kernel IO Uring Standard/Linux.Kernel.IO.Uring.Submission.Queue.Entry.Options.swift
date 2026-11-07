#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt8

            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }

            public static let fixedFile = Options(rawValue: 1 << 0)

            public static let ioDrain = Options(rawValue: 1 << 1)

            public static let ioLink = Options(rawValue: 1 << 2)

            public static let ioHardlink = Options(rawValue: 1 << 3)

            public static let async = Options(rawValue: 1 << 4)

            public static let bufferSelect = Options(rawValue: 1 << 5)

            public static let cqeSkipSuccess = Options(rawValue: 1 << 6)
        }
    }

#endif
