#if os(Linux)

public import Kernel_File_Primitives

#if canImport(CLinuxKernelShim)
    internal import CLinuxKernelShim
#endif

extension Kernel.File.Open {
    /// Path resolution flags for openat2(2).
    ///
    /// Controls how path components are resolved during the open operation.
    public struct Resolve: OptionSet, Sendable {
        public let rawValue: UInt64

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension Kernel.File.Open.Resolve {
    /// Disallow path resolution to escape beneath the directory fd.
    public static let beneath = Self(rawValue: UInt64(RESOLVE_BENEATH))

    /// Treat the directory fd as the filesystem root.
    public static let inRoot = Self(rawValue: UInt64(RESOLVE_IN_ROOT))

    /// Disallow resolution of magic links (e.g., /proc/self/fd/*).
    public static let noMagicLinks = Self(rawValue: UInt64(RESOLVE_NO_MAGICLINKS))

    /// Disallow resolution of all symbolic links.
    public static let noSymlinks = Self(rawValue: UInt64(RESOLVE_NO_SYMLINKS))

    /// Disallow traversal of mount points.
    public static let noXdev = Self(rawValue: UInt64(RESOLVE_NO_XDEV))

    /// Fail unless all path components are in the kernel lookup cache.
    public static let cached = Self(rawValue: UInt64(RESOLVE_CACHED))
}

#endif
