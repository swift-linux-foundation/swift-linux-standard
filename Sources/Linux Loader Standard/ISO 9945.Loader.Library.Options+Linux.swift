#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Loader
    public import Loader_Primitives

    private let _RTLD_NOLOAD: Int32 = 0x0000_4

    private let _RTLD_NODELETE: Int32 = 0x1000

    extension ISO_9945.Loader.Library.Options {

        public static let noLoad = Self(rawValue: _RTLD_NOLOAD)

        public static let noDelete = Self(rawValue: _RTLD_NODELETE)
    }

#endif
