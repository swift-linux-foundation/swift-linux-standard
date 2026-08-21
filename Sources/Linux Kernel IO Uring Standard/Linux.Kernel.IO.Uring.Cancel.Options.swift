#if os(Linux)

    public import ISO_9945_Core
    public import Error_Primitives
    public import Memory_Primitives

    extension ISO_9945.Kernel.IO.Uring.Cancel {

        public struct Options: OptionSet, Sendable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let all = Options(rawValue: 1 << 0)

            public static let fd = Options(rawValue: 1 << 1)

            public static let any = Options(rawValue: 1 << 2)

            public static let fdFixed = Options(rawValue: 1 << 3)

            public static let userData = Options(rawValue: 1 << 4)

            public static let op = Options(rawValue: 1 << 5)
        }
    }

#endif
