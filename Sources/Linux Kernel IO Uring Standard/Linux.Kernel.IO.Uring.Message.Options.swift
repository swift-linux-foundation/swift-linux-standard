#if os(Linux)

    public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    private let _IORING_MSG_RING_CQE_SKIP: UInt32 = 1 << 0

    private let _IORING_MSG_RING_FLAGS_PASS: UInt32 = 1 << 1

    extension ISO_9945.Kernel.IO.Uring {

        public struct Message: Sendable {

            public struct Options: OptionSet, Sendable {
                public let rawValue: UInt32

                @inlinable
                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                public static let cqeSkip = Options(rawValue: _IORING_MSG_RING_CQE_SKIP)

                public static let flagsPass = Options(rawValue: _IORING_MSG_RING_FLAGS_PASS)
            }
        }
    }

#endif
