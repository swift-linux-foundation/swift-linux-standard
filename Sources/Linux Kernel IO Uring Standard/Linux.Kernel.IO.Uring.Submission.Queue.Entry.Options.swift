#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Submission.Queue.Entry {
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt8

            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Submission.Queue.Entry.Options {
        public static let fixedFile = Linux.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 0)

        public static let ioDrain = Linux.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 1)

        public static let ioLink = Linux.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 2)

        public static let ioHardlink = Linux.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 3)

        public static let async = Linux.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 4)

        public static let bufferSelect = Linux.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 5)

        public static let cqeSkipSuccess = Linux.Kernel.IO.Uring.Submission.Queue.Entry.Options(rawValue: 1 << 6)
    }

#endif
