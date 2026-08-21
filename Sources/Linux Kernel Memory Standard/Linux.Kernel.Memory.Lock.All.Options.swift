#if os(Linux)

    public import ISO_9945_Core
    public import Error_Primitives
    public import Memory_Primitives
    public import Path_Primitives
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
