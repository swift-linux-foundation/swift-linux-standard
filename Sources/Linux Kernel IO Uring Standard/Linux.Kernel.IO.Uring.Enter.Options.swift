#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Enter {
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Enter.Options {
        public static let getEvents = Linux.Kernel.IO.Uring.Enter.Options(rawValue: 1 << 0)

        public static let sqWakeup = Linux.Kernel.IO.Uring.Enter.Options(rawValue: 1 << 1)

        public static let sqWait = Linux.Kernel.IO.Uring.Enter.Options(rawValue: 1 << 2)

        public static let extArg = Linux.Kernel.IO.Uring.Enter.Options(rawValue: 1 << 3)

        public static let registeredRing = Linux.Kernel.IO.Uring.Enter.Options(rawValue: 1 << 4)

        public static let absoluteTimer = Linux.Kernel.IO.Uring.Enter.Options(rawValue: 1 << 5)
    }

#endif
