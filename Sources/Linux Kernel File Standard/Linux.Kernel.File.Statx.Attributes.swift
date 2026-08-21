#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.File.Statx {

        public struct Attributes: OptionSet, Sendable {
            public let rawValue: UInt64

            public init(rawValue: UInt64) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.File.Statx.Attributes {

        public static let compressed = Self(rawValue: UInt64(STATX_ATTR_COMPRESSED))

        public static let immutable = Self(rawValue: UInt64(STATX_ATTR_IMMUTABLE))

        public static let append = Self(rawValue: UInt64(STATX_ATTR_APPEND))

        public static let noDump = Self(rawValue: UInt64(STATX_ATTR_NODUMP))

        public static let encrypted = Self(rawValue: UInt64(STATX_ATTR_ENCRYPTED))

        public static let verity = Self(rawValue: UInt64(STATX_ATTR_VERITY))

        public static let dax = Self(rawValue: UInt64(STATX_ATTR_DAX))
    }

#endif
