#if os(Linux)

    public import Linux_Standard_Core

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Glibc) || canImport(Musl)
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.Pipe {

        public struct Options: OptionSet, Sendable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.Pipe.Options {

        public static let closeOnExec = Self(rawValue: O_CLOEXEC)

        public static let nonBlock = Self(rawValue: O_NONBLOCK)

        public static let direct = Self(rawValue: O_DIRECT)
    }

#endif
