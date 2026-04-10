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
public import Kernel_Random_Primitives
public import Kernel_Path_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux-specific mlockall Flags

extension Kernel.Memory.Lock.All.Flags {
    /// Lock pages when they are faulted in (Linux 4.4+).
    ///
    /// This avoids the overhead of faulting in all pages immediately.
    public static let onFault = Self(rawValue: 4) // MCL_ONFAULT
}

#endif
