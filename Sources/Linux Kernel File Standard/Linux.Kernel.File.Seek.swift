#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error
    public import Memory
    public import Path

    extension ISO_9945.Kernel.File.Seek.Whence {

        public static let hole = Self(rawValue: 4)

        public static let data = Self(rawValue: 3)
    }

#endif
