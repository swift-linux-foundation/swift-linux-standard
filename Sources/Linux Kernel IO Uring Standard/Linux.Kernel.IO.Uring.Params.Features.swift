#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Params {

        public struct Features: Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Params.Features {

        public static let singleMmap = Self(rawValue: 1 << 0)

        public static let noDrop = Self(rawValue: 1 << 1)

        public static let submitStable = Self(rawValue: 1 << 2)

        public static let rwCurrentPosition = Self(rawValue: 1 << 3)

        public static let currentPersonality = Self(rawValue: 1 << 4)

        public static let fastPoll = Self(rawValue: 1 << 5)

        public static let poll32Bits = Self(rawValue: 1 << 6)

        public static let sqPollNonFixed = Self(rawValue: 1 << 7)

        public static let extArg = Self(rawValue: 1 << 8)

        public static let nativeWorkers = Self(rawValue: 1 << 9)

        public static let resourceTags = Self(rawValue: 1 << 10)

        public static let cqeSkip = Self(rawValue: 1 << 11)

        public static let linkedFile = Self(rawValue: 1 << 12)

        public static let regRegRing = Self(rawValue: 1 << 13)

        public static let receiveSendBundle = Self(rawValue: 1 << 14)

        public static let minimumTimeout = Self(rawValue: 1 << 15)
    }

    extension ISO_9945.Kernel.IO.Uring.Params.Features {

        @inlinable
        public func contains(_ feature: Self) -> Bool {
            rawValue & feature.rawValue == feature.rawValue
        }
    }

#endif
