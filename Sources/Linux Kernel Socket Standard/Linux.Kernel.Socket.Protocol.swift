#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_Socket
    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.Socket {

        public struct `Protocol`: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.Socket.`Protocol` {

        public static let auto = Self(rawValue: 0)

        public static let tcp = Self(rawValue: Int32(IPPROTO_TCP))

        public static let udp = Self(rawValue: Int32(IPPROTO_UDP))

        public static let raw = Self(rawValue: Int32(IPPROTO_RAW))

        public static let sctp = Self(rawValue: Int32(IPPROTO_SCTP))
    }

#endif
