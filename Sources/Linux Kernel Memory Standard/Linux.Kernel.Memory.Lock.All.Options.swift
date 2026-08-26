#if os(Linux)

    public import ISO_9945_Core
    public import Error
    public import Memory
    public import Path
    public import ISO_9945_Kernel_Memory

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Memory.Lock.All.Options {

        public static let onFault = Self(rawValue: 4)
    }

#endif
