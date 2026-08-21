#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.File {

        public struct Statx: @unchecked Sendable {
            internal var cValue: statx

            public init() {
                self.cValue = statx()
            }
        }
    }

    extension ISO_9945.Kernel.File.Statx {

        public var mask: Mask {
            get { Mask(rawValue: cValue.stx_mask) }
            set { cValue.stx_mask = newValue.rawValue }
        }

        public var blockSize: UInt32 {
            cValue.stx_blksize
        }

        public var attributes: Attributes {
            Attributes(rawValue: cValue.stx_attributes)
        }

        public var linkCount: UInt32 {
            cValue.stx_nlink
        }

        public var uid: ISO_9945.Kernel.User.ID {
            ISO_9945.Kernel.User.ID(_unchecked: cValue.stx_uid)
        }

        public var gid: ISO_9945.Kernel.Group.ID {
            ISO_9945.Kernel.Group.ID(_unchecked: cValue.stx_gid)
        }

        public var mode: UInt16 {
            cValue.stx_mode
        }

        public var permissions: ISO_9945.Kernel.File.Permissions {
            ISO_9945.Kernel.File.Permissions(rawValue: cValue.stx_mode & 0o7777)
        }

        public var inode: UInt64 {
            cValue.stx_ino
        }

        public var size: ISO_9945.Kernel.File.Size {
            ISO_9945.Kernel.File.Size(Int64(cValue.stx_size))
        }

        public var blocks: UInt64 {
            cValue.stx_blocks
        }

        public var attributesMask: Attributes {
            Attributes(rawValue: cValue.stx_attributes_mask)
        }

        public var accessTime: Timestamp {
            Timestamp(cValue.stx_atime)
        }

        public var birthTime: Timestamp {
            Timestamp(cValue.stx_btime)
        }

        public var changeTime: Timestamp {
            Timestamp(cValue.stx_ctime)
        }

        public var modificationTime: Timestamp {
            Timestamp(cValue.stx_mtime)
        }

        public var deviceMajor: UInt32 {
            cValue.stx_dev_major
        }

        public var deviceMinor: UInt32 {
            cValue.stx_dev_minor
        }

        public var rdevMajor: UInt32 {
            cValue.stx_rdev_major
        }

        public var rdevMinor: UInt32 {
            cValue.stx_rdev_minor
        }

        public var mountId: UInt64 {
            withUnsafePointer(to: cValue) { swift_statx_get_mnt_id($0) }
        }
    }

#endif
