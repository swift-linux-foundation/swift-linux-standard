#if os(Linux)

    public import ISO_9945_Core
    public import Error_Primitives
    public import Memory_Primitives
    public import Path_Primitives

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
