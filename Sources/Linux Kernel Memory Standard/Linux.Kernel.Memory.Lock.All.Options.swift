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

public import Error_Primitives
public import Memory_Primitives
public import Path_Primitives
public import ISO_9945_Kernel_Memory

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux-specific mlockall Options

extension Memory.Lock.All.Options {
    /// Lock pages when they are faulted in (Linux 4.4+).
    ///
    /// This avoids the overhead of faulting in all pages immediately.
    public static let onFault = Self(rawValue: 4) // MCL_ONFAULT
}

#endif
