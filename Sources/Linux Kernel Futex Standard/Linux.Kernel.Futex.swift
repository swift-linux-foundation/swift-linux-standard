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

public import Kernel_Primitives_Core
public import Kernel_Descriptor_Primitives
public import Kernel_Error_Primitives
public import Kernel_File_Primitives
public import Kernel_Memory_Primitives
public import Kernel_Path_Primitives

// MARK: - Linux Futex Namespace

extension Kernel {
    /// Linux futex (fast userspace mutex) operations.
    ///
    /// Namespace for futex(2) related types. Futexes provide the kernel-side
    /// building block for userspace synchronization primitives.
    public struct Futex: Sendable {}
}

#endif
