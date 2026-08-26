#if os(Linux)

    public import ISO_9945_Core
    public import Error
    public import Memory
    public import Path

    extension ISO_9945.Kernel.Futex {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let privateFlag = Self(rawValue: 128)

            public static let clockRealtime = Self(rawValue: 256)
        }
    }

#endif
