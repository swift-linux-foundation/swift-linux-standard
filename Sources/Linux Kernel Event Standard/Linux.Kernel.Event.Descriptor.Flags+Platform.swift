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

    extension Linux.Kernel.Event.Descriptor.Flags {

        public static let cloexec = Self(rawValue: Int32(EFD_CLOEXEC))

        public static let nonblock = Self(rawValue: Int32(EFD_NONBLOCK))

        public static let semaphore = Self(rawValue: Int32(EFD_SEMAPHORE))
    }

#endif
