#if os(Linux)

public import ISO_9945_Core
public import ISO_9945_Kernel_File
#if canImport(CLinuxKernelShim)
    internal import CLinuxKernelShim
#endif

extension ISO_9945.Kernel.File.Statx {
    /// Extended file attribute flags.
    public struct Attributes: OptionSet, Sendable {
        public let rawValue: UInt64

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension ISO_9945.Kernel.File.Statx.Attributes {
    /// File is compressed by the filesystem.
    public static let compressed = Self(rawValue: UInt64(STATX_ATTR_COMPRESSED))

    /// File cannot be modified.
    public static let immutable = Self(rawValue: UInt64(STATX_ATTR_IMMUTABLE))

    /// File can only be opened in append mode.
    public static let append = Self(rawValue: UInt64(STATX_ATTR_APPEND))

    /// File is not a candidate for backup.
    public static let noDump = Self(rawValue: UInt64(STATX_ATTR_NODUMP))

    /// File requires a key to be decrypted.
    public static let encrypted = Self(rawValue: UInt64(STATX_ATTR_ENCRYPTED))

    /// File has fs-verity enabled.
    public static let verity = Self(rawValue: UInt64(STATX_ATTR_VERITY))

    /// File is in DAX (direct access) state.
    public static let dax = Self(rawValue: UInt64(STATX_ATTR_DAX))
}

#endif
