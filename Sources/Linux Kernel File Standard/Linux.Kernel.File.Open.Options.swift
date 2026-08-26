#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error
    public import Memory
    public import Path

    #if canImport(Glibc)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.File.Open.Options {

        public static let direct = Self(rawValue: O_DIRECT)
    }

#endif
