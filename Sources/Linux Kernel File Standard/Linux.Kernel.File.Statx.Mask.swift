#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.File.Statx {

        public struct Mask: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.File.Statx.Mask {

        public static let type = Self(rawValue: UInt32(STATX_TYPE))

        public static let mode = Self(rawValue: UInt32(STATX_MODE))

        public static let linkCount = Self(rawValue: UInt32(STATX_NLINK))

        public static let uid = Self(rawValue: UInt32(STATX_UID))

        public static let gid = Self(rawValue: UInt32(STATX_GID))

        public static let accessTime = Self(rawValue: UInt32(STATX_ATIME))

        public static let modificationTime = Self(rawValue: UInt32(STATX_MTIME))

        public static let changeTime = Self(rawValue: UInt32(STATX_CTIME))

        public static let inode = Self(rawValue: UInt32(STATX_INO))

        public static let size = Self(rawValue: UInt32(STATX_SIZE))

        public static let blocks = Self(rawValue: UInt32(STATX_BLOCKS))

        public static let basicStats = Self(rawValue: UInt32(STATX_BASIC_STATS))

        public static let birthTime = Self(rawValue: UInt32(STATX_BTIME))

        public static let mountId = Self(rawValue: UInt32(STATX_MNT_ID))
    }

#endif
