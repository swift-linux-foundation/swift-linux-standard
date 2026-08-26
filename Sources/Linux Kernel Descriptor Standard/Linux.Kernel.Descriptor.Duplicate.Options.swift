#if os(Linux)

    public import ISO_9945_Core
    public import Error
    public import Memory
    public import Path

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.Descriptor.Duplicate {

        public struct Options: OptionSet, Sendable, Equatable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }

            public static let closeOnExec = Self(rawValue: O_CLOEXEC)
        }
    }

#endif
