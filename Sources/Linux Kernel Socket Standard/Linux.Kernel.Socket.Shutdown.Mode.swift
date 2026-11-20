#if os(Linux)

    public import Linux_Standard_Core

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Linux.Kernel.Socket.Shutdown {

        public struct Mode: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.Socket.Shutdown.Mode {

        public static let read = Self(rawValue: Int32(SHUT_RD))

        public static let write = Self(rawValue: Int32(SHUT_WR))

        public static let both = Self(rawValue: Int32(SHUT_RDWR))
    }

#endif
