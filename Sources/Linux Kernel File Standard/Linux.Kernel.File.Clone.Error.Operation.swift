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

extension Linux.Kernel.File.Clone.Error {
    /// The Linux syscall that produced a ``Linux/Kernel/File/Clone/Error/Syscall``.
    public enum Operation: Swift.String, Sendable, Equatable {
        /// `statfs(2)`, used to probe clone capability.
        case statfs

        /// `stat(2)`, used to read file metadata.
        case stat

        /// `ioctl(FICLONE)`, used to attempt a copy-on-write clone.
        case ficlone

        /// `copy_file_range(2)`, used for kernel-space copy.
        case copyFileRange
    }
}
