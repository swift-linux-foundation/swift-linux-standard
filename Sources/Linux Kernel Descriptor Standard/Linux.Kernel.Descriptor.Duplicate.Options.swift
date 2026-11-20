#if os(Linux)

    public import Linux_Standard_Core
    public import ISO_9945_Core
    import Error
    import Memory
    import Path

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Linux.Kernel.Descriptor.Duplicate {
        public struct Options: OptionSet, Sendable, Equatable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.Descriptor.Duplicate.Options {
        public static let closeOnExec = Self(rawValue: O_CLOEXEC)
    }

#endif
