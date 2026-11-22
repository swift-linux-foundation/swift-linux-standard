#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    import Error
    import Memory

    extension Linux.Kernel.IO.Uring.Cancel {
        public struct Options: OptionSet, Sendable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Cancel.Options {
        public static let all = Linux.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 0)

        public static let fd = Linux.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 1)

        public static let any = Linux.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 2)

        public static let fdFixed = Linux.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 3)

        public static let userData = Linux.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 4)

        public static let op = Linux.Kernel.IO.Uring.Cancel.Options(rawValue: 1 << 5)
    }

#endif
