#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Nop {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Nop.Options {

        public static let injectResult = Self(rawValue: 1 << 0)
    }

#endif
