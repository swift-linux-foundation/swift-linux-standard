// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Linux {
    /// Linux kernel mechanisms — distinct nominal type per [PLAT-ARCH-008k]
    /// Spec/Policy Namespace Split. Linux-specific spec content (ABI structs,
    /// Linux-only syscalls like `getrandom(2)`) lives here; POSIX-shared
    /// content stays at `ISO_9945.Kernel`. Resolves the [PLAT-ARCH-018] silent
    /// typealias-conflict hazard between `Linux.Kernel` and `ISO_9945.Kernel`.
    public enum Kernel: Sendable {}
}
