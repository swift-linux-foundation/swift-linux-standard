#if os(Linux)

public import ISO_9945_Core
public import ISO_9945_Kernel_File
#if canImport(CLinuxKernelShim)
    internal import CLinuxKernelShim
#endif

extension ISO_9945.Kernel.File {
    /// Extended file status information from statx(2).
    ///
    /// Wraps the platform `struct statx`. An `UnsafeMutablePointer<Statx>`
    /// may be passed directly to kernel interfaces that expect `struct statx *`.
    public struct Statx: @unchecked Sendable {
        internal var cValue: statx

        /// Creates a zeroed statx buffer.
        public init() {
            self.cValue = statx()
        }
    }
}

// MARK: - Accessors

extension ISO_9945.Kernel.File.Statx {
    /// Which fields the kernel populated.
    public var mask: Mask {
        get { Mask(rawValue: cValue.stx_mask) }
        set { cValue.stx_mask = newValue.rawValue }
    }

    /// Preferred I/O block size.
    public var blockSize: UInt32 {
        get { cValue.stx_blksize }
    }

    /// File attributes.
    public var attributes: Attributes {
        get { Attributes(rawValue: cValue.stx_attributes) }
    }

    /// Hard link count.
    public var linkCount: UInt32 {
        get { cValue.stx_nlink }
    }

    /// Owner user ID.
    public var uid: ISO_9945.Kernel.User.ID {
        get { ISO_9945.Kernel.User.ID(_unchecked: cValue.stx_uid) }
    }

    /// Owner group ID.
    public var gid: ISO_9945.Kernel.Group.ID {
        get { ISO_9945.Kernel.Group.ID(_unchecked: cValue.stx_gid) }
    }

    /// Raw file mode (type + permission bits).
    public var mode: UInt16 {
        get { cValue.stx_mode }
    }

    /// File permission bits only.
    public var permissions: ISO_9945.Kernel.File.Permissions {
        get { ISO_9945.Kernel.File.Permissions(rawValue: cValue.stx_mode & 0o7777) }
    }

    /// Inode number.
    public var inode: UInt64 {
        get { cValue.stx_ino }
    }

    /// File size in bytes.
    public var size: ISO_9945.Kernel.File.Size {
        get { ISO_9945.Kernel.File.Size(Int64(cValue.stx_size)) }
    }

    /// Number of 512-byte blocks allocated.
    public var blocks: UInt64 {
        get { cValue.stx_blocks }
    }

    /// Supported attributes mask.
    public var attributesMask: Attributes {
        get { Attributes(rawValue: cValue.stx_attributes_mask) }
    }

    /// Last access time.
    public var accessTime: Timestamp {
        get { Timestamp(cValue.stx_atime) }
    }

    /// Creation (birth) time.
    public var birthTime: Timestamp {
        get { Timestamp(cValue.stx_btime) }
    }

    /// Last status change time.
    public var changeTime: Timestamp {
        get { Timestamp(cValue.stx_ctime) }
    }

    /// Last modification time.
    public var modificationTime: Timestamp {
        get { Timestamp(cValue.stx_mtime) }
    }

    /// Device major number (for the containing filesystem).
    public var deviceMajor: UInt32 {
        get { cValue.stx_dev_major }
    }

    /// Device minor number (for the containing filesystem).
    public var deviceMinor: UInt32 {
        get { cValue.stx_dev_minor }
    }

    /// Device major number (for device files).
    public var rdevMajor: UInt32 {
        get { cValue.stx_rdev_major }
    }

    /// Device minor number (for device files).
    public var rdevMinor: UInt32 {
        get { cValue.stx_rdev_minor }
    }

    /// Mount ID.
    public var mountId: UInt64 {
        get { cValue.stx_mnt_id }
    }
}

#endif
