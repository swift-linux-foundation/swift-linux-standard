#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.File.At.Options {

        public static let emptyPath = Self(rawValue: Int32(AT_EMPTY_PATH))
    }

#endif
