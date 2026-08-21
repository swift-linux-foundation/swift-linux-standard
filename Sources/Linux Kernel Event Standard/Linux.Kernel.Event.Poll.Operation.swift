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

    extension Linux.Kernel.Event.Poll {

        public struct Operation: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.Event.Poll.Operation {

        public static let add = Self(rawValue: EPOLL_CTL_ADD)

        public static let modify = Self(rawValue: EPOLL_CTL_MOD)

        public static let delete = Self(rawValue: EPOLL_CTL_DEL)
    }

#endif
