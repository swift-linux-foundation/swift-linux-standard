#if os(Linux)

    public import ISO_9945_Core
    import Error
    import Memory

    extension ISO_9945.Kernel.IO.Uring.Cancel {
        public struct Options: OptionSet, Sendable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Cancel.Options {
        public static let all = ISO_9945.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 0)

        public static let fd = ISO_9945.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 1)

        public static let any = ISO_9945.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 2)

        public static let fdFixed = ISO_9945.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 3)

        public static let userData = ISO_9945.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 4)

        public static let op = ISO_9945.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 5)
    }

#endif
