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

extension Linux.Kernel.File.Clone {
    /// Namespace for errors from Linux clone mechanisms (`FICLONE`,
    /// `copy_file_range(2)`). See ``Linux/Kernel/File/Clone/Error/Syscall``
    /// for the raw syscall-level error surface.
    public enum Error: Sendable {}
}
