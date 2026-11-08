#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt8

            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry.Options {
        public static let fixedFile = ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 0)

        public static let ioDrain = ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 1)

        public static let ioLink = ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 2)

        public static let ioHardlink = ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 3)

        public static let async = ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 4)

        public static let bufferSelect = ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 5)

        public static let cqeSkipSuccess = ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 6)
    }

#endif
