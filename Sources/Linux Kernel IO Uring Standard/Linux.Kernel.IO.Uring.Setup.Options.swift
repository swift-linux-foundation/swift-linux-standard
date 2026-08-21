#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Setup {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Setup.Options {

        public static let ioPoll = Self(rawValue: 1 << 0)

        public static let sqPoll = Self(rawValue: 1 << 1)

        public static let sqAff = Self(rawValue: 1 << 2)

        public static let cqSize = Self(rawValue: 1 << 3)

        public static let clamp = Self(rawValue: 1 << 4)

        public static let attachWq = Self(rawValue: 1 << 5)

        public static let rDisabled = Self(rawValue: 1 << 6)

        public static let submitAll = Self(rawValue: 1 << 7)

        public static let coopTaskrun = Self(rawValue: 1 << 8)

        public static let taskrunFlag = Self(rawValue: 1 << 9)

        public static let sqe128 = Self(rawValue: 1 << 10)

        public static let cqe32 = Self(rawValue: 1 << 11)

        public static let singleIssuer = Self(rawValue: 1 << 12)

        public static let deferTaskrun = Self(rawValue: 1 << 13)

        public static let noMemoryMap = Self(rawValue: 1 << 14)

        public static let registeredDescriptorOnly = Self(rawValue: 1 << 15)

        public static let noSubmissionArray = Self(rawValue: 1 << 16)
    }

#endif
