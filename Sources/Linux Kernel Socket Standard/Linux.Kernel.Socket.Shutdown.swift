#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_Socket
    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.Socket.Shutdown {

        public struct Mode: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.Socket.Shutdown.Mode {

        public static let read = Self(rawValue: Int32(SHUT_RD))

        public static let write = Self(rawValue: Int32(SHUT_WR))

        public static let both = Self(rawValue: Int32(SHUT_RDWR))
    }

#endif
