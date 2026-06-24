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

@_spi(Syscall) public import ISO_9945_Core
public import ISO_9945_Kernel_File
public import Error_Primitives

#if canImport(Glibc)
    internal import Glibc
    internal import CLinuxKernelShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - copy_file_range Implementation — raw fd SPI

extension ISO_9945.Kernel.Copy.Range {
    /// Copies bytes between file descriptors using copy_file_range(2) — raw fd SPI.
    ///
    /// Spec-literal: takes raw `Int32` fds. The L3-policy typed-descriptor
    /// convenience (with `ISO_9945.Kernel.Descriptor.Validity` checks) lives at
    /// swift-linux per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    ///
    /// This Linux-specific syscall performs efficient kernel-space copying,
    /// avoiding unnecessary data transfer to userspace. On supported filesystems,
    /// it may use copy-on-write or server-side copy.
    ///
    /// ## Threading
    /// This call blocks until at least some bytes are copied or an error occurs.
    /// May copy fewer bytes than requested (similar to read/write). Safe to call
    /// concurrently if operating on non-overlapping regions.
    ///
    /// ## Filesystem Support
    /// - **NFS**: Server-side copy (data doesn't traverse network twice)
    /// - **Btrfs/XFS**: May use reflinks for same-filesystem copies
    /// - **Other**: Falls back to efficient kernel-space copy
    ///
    /// ## Partial Copies
    /// May return fewer bytes than `length`. This is not an error—loop until
    /// all data is copied or the source is exhausted (returns 0).
    ///
    /// ## Errors
    /// - ``Kernel/Copy/Error/crossDevice``: Offload not supported across devices
    /// - ``Kernel/Copy/Error/io``: I/O error during copy
    ///
    /// - Parameters:
    ///   - sourceFd: Source file raw fd (open for reading).
    ///   - sourceOffset: Offset in source file (updated on return).
    ///   - destinationFd: Destination file raw fd (open for writing).
    ///   - destOffset: Offset in destination file (updated on return).
    ///   - length: Maximum number of bytes to copy.
    /// - Returns: Number of bytes copied (may be less than `length`).
    /// - Throws: ``Kernel/Copy/Error`` on failure.
    @_spi(Syscall) public static func copy(
        fromFd sourceFd: Int32,
        sourceOffset: inout ISO_9945.Kernel.File.Offset,
        toFd destinationFd: Int32,
        destOffset: inout ISO_9945.Kernel.File.Offset,
        length: ISO_9945.Kernel.File.Size
    ) throws(ISO_9945.Kernel.Copy.Error) -> ISO_9945.Kernel.File.Size {
        var srcOff = off_t(sourceOffset.underlying)
        var dstOff = off_t(destOffset.underlying)

        let result = Int(
            swift_copy_file_range(
                sourceFd,
                &srcOff,
                destinationFd,
                &dstOff,
                size_t(Int(length)),
                0
            )
        )

        guard result >= 0 else {
            throw ISO_9945.Kernel.Copy.Error(posixErrno: errno)
        }

        sourceOffset = ISO_9945.Kernel.File.Offset(Int64(srcOff))
        destOffset = ISO_9945.Kernel.File.Offset(Int64(dstOff))
        return ISO_9945.Kernel.File.Size(Int64(result))
    }
}

#endif
