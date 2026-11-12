#if os(Linux)

    public import Linux_Standard_Core
    import Error

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

        #if canImport(Glibc)
            internal init(_ event: EPOLL_EVENTS) {
                self.init(rawValue: event.rawValue)
            }
        #else
            internal init(_ event: some BinaryInteger) {
                self.init(rawValue: UInt32(truncatingIfNeeded: event))
            }
        #endif
    }

    extension Linux.Kernel.Event.Poll.Events {

        public static let `in` = Self(EPOLLIN)

        public static let out = Self(EPOLLOUT)

        public static let rdhup = Self(EPOLLRDHUP)

        public static let pri = Self(EPOLLPRI)

        public static let err = Self(EPOLLERR)

        public static let hup = Self(EPOLLHUP)

        public static let et = Self(EPOLLET)

        public static let oneshot = Self(EPOLLONESHOT)
    }

#endif
