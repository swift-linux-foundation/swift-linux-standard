// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

@_spi(Syscall) public import Kernel_Primitives

#if canImport(Glibc)
    internal import Glibc
    internal import CLinuxKernelShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux FICLONE Implementation

extension Kernel.Copy.Clone {
    /// Clones a file using FICLONE ioctl, creating a copy-on-write duplicate.
    ///
    /// Both files share the same data blocks until one is modified, making this
    /// extremely fast for large files on supported filesystems.
    ///
    /// ## Threading
    /// This call blocks until the clone operation completes. The clone is atomic
    /// from the filesystem's perspective.
    ///
    /// ## Filesystem Support
    /// Only works on filesystems with reflink capability:
    /// - Btrfs (full support)
    /// - XFS (with reflink enabled)
    ///
    /// ## Errors
    /// - ``Kernel/Copy/Error/invalidDescriptor``: Source or destination is invalid
    /// - ``Kernel/Copy/Error/unsupported``: Filesystem doesn't support FICLONE
    /// - ``Kernel/Copy/Error/crossDevice``: Source and destination on different filesystems
    /// - ``Kernel/Copy/Error/notEmpty``: Destination file is not empty
    ///
    /// - Parameters:
    ///   - source: Source file descriptor (open for reading).
    ///   - destination: Destination file descriptor (must be empty, open for writing).
    /// - Throws: ``Kernel/Copy/Error`` on failure.

    public static func perform(
        from source: borrowing Kernel.Descriptor,
        to destination: borrowing Kernel.Descriptor
    ) throws(Kernel.Copy.Error) {
        guard source.isValid else { throw .invalidDescriptor }
        guard destination.isValid else { throw .invalidDescriptor }

        let result = swift_ficlone(destination._rawValue, source._rawValue)
        guard result == 0 else {
            throw Kernel.Copy.Error(posixErrno: errno)
        }
    }
}

#endif
