#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.File.Open {

        public struct Resolve: OptionSet, Sendable {
            public let rawValue: UInt64

            public init(rawValue: UInt64) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.File.Open.Resolve {

        public static let beneath = Self(rawValue: UInt64(RESOLVE_BENEATH))

        public static let inRoot = Self(rawValue: UInt64(RESOLVE_IN_ROOT))

        public static let noMagicLinks = Self(rawValue: UInt64(RESOLVE_NO_MAGICLINKS))

        public static let noSymlinks = Self(rawValue: UInt64(RESOLVE_NO_SYMLINKS))

        public static let noXdev = Self(rawValue: UInt64(RESOLVE_NO_XDEV))

        public static let cached = Self(rawValue: UInt64(RESOLVE_CACHED))
    }

#endif
