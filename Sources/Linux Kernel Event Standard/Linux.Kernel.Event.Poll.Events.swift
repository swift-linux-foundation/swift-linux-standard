#if os(Linux)

    public import Linux_Standard_Core
    public import Error

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.Event.Poll {

        public struct Events: OptionSet, Sendable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.Event.Poll.Events {

        public static let `in` = Self(rawValue: EPOLLIN.rawValue)

        public static let out = Self(rawValue: EPOLLOUT.rawValue)

        public static let rdhup = Self(rawValue: EPOLLRDHUP.rawValue)

        public static let pri = Self(rawValue: EPOLLPRI.rawValue)

        public static let err = Self(rawValue: EPOLLERR.rawValue)

        public static let hup = Self(rawValue: EPOLLHUP.rawValue)

        public static let et = Self(rawValue: EPOLLET.rawValue)

        public static let oneshot = Self(rawValue: EPOLLONESHOT.rawValue)
    }

#endif
