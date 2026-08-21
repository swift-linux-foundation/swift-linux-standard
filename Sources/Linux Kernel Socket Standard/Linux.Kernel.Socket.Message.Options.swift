#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_Socket
    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.Socket.Message.Options {

        public static let more = Self(rawValue: Int32(MSG_MORE))

        public static let confirm = Self(rawValue: Int32(MSG_CONFIRM))
    }

#endif
