// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-linux-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Linux_Standard_Core

extension Linux.Kernel.Copy {
    /// Errors from `copy_file_range(2)` / `FICLONE` copy operations.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Invalid file descriptor.
        /// - POSIX: `EBADF`
        case invalidDescriptor

        /// Cross-device copy not supported.
        /// - POSIX: `EXDEV`
        ///
        /// The source and destination are on different filesystems.
        case crossDevice

        /// Operation not supported.
        /// - POSIX: `EINVAL`, `ENOTSUP`
        ///
        /// The filesystem or file type doesn't support this operation.
        case unsupported

        /// No space left on device.
        /// - POSIX: `ENOSPC`
        case noSpace

        /// Physical I/O error.
        /// - POSIX: `EIO`
        case io

        /// Permission denied.
        /// - POSIX: `EACCES`, `EPERM`
        case permissionDenied

        /// Destination already exists.
        /// - POSIX: `EEXIST`
        case exists

        /// Source not found.
        /// - POSIX: `ENOENT`
        case notFound
    }
}
