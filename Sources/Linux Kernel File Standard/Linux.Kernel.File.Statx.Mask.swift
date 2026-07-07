#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension ISO_9945.Kernel.File.Statx {
        /// Mask indicating which statx fields to populate or were populated.
        public struct Mask: OptionSet, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    // MARK: - Constants

    extension ISO_9945.Kernel.File.Statx.Mask {
        /// File type (from mode).
        public static let type = Self(rawValue: UInt32(STATX_TYPE))

        /// File permissions (from mode).
        public static let mode = Self(rawValue: UInt32(STATX_MODE))

        /// Hard link count.
        public static let linkCount = Self(rawValue: UInt32(STATX_NLINK))

        /// Owner user ID.
        public static let uid = Self(rawValue: UInt32(STATX_UID))

        /// Owner group ID.
        public static let gid = Self(rawValue: UInt32(STATX_GID))

        /// Last access time.
        public static let accessTime = Self(rawValue: UInt32(STATX_ATIME))

        /// Last modification time.
        public static let modificationTime = Self(rawValue: UInt32(STATX_MTIME))

        /// Last status change time.
        public static let changeTime = Self(rawValue: UInt32(STATX_CTIME))

        /// Inode number.
        public static let inode = Self(rawValue: UInt32(STATX_INO))

        /// File size.
        public static let size = Self(rawValue: UInt32(STATX_SIZE))

        /// Allocated blocks.
        public static let blocks = Self(rawValue: UInt32(STATX_BLOCKS))

        /// All basic stat fields.
        public static let basicStats = Self(rawValue: UInt32(STATX_BASIC_STATS))

        /// Creation (birth) time.
        public static let birthTime = Self(rawValue: UInt32(STATX_BTIME))

        /// Mount ID.
        public static let mountId = Self(rawValue: UInt32(STATX_MNT_ID))
    }

#endif
