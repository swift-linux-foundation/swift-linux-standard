#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error_Primitives
    public import Memory_Primitives
    public import Path_Primitives

    extension ISO_9945.Kernel.File.Seek.Whence {

        public static let hole = Self(rawValue: 4)

        public static let data = Self(rawValue: 3)
    }

#endif
