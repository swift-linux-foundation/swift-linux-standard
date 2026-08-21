#if os(Linux)

    public import Linux_Standard_Core
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.Event.Poll.Create {

        public struct Flags: OptionSet, Sendable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.Event.Poll.Create.Flags {

        public static let none = Self(rawValue: 0)

        public static let cloexec = Self(rawValue: Int32(EPOLL_CLOEXEC))
    }

#endif
