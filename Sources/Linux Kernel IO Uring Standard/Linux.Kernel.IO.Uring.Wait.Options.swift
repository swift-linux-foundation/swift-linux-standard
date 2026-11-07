#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Wait {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let none = Options([])
        }
    }

#endif
