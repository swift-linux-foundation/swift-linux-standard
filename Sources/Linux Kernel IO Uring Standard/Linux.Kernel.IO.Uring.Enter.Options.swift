#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Enter {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let getEvents = Options(rawValue: 1 << 0)

            public static let sqWakeup = Options(rawValue: 1 << 1)

            public static let sqWait = Options(rawValue: 1 << 2)

            public static let extArg = Options(rawValue: 1 << 3)

            public static let registeredRing = Options(rawValue: 1 << 4)

            public static let absoluteTimer = Options(rawValue: 1 << 5)
        }
    }

#endif
