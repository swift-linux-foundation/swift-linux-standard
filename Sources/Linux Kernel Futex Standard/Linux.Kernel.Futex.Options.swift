#if os(Linux)

    public import Linux_Standard_Core
    import ISO_9945_Core
    import Error
    import Memory
    import Path

    extension Linux.Kernel.Futex {
        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.Futex.Options {
        public static let privateFlag = Self(rawValue: 128)

        public static let clockRealtime = Self(rawValue: 256)
    }

#endif
