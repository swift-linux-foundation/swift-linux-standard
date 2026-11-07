#if os(Linux)

    public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    private let _IORING_FIXED_FD_NO_CLOEXEC: UInt32 = 1 << 0

    extension ISO_9945.Kernel.IO.Uring.Fixed {

        public struct Install: Sendable {
            public struct Options: OptionSet, Sendable {
                public let rawValue: UInt32

                @inlinable
                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                public static let noCloseOnExec = Options(rawValue: _IORING_FIXED_FD_NO_CLOEXEC)
            }
        }
    }

#endif
