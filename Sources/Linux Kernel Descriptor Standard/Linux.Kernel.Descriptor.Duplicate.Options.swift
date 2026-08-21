#if os(Linux)

    public import ISO_9945_Core
    public import Error_Primitives
    public import Memory_Primitives
    public import Path_Primitives

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
