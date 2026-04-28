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

// MARK: - Linux-specific Seek Whence

extension Kernel.File.Seek.Whence {
    /// Seek to the next hole (Linux 3.1+, SEEK_HOLE = 4).
    public static let hole = Self(rawValue: 4)

    /// Seek to the next data region (Linux 3.1+, SEEK_DATA = 3).
    public static let data = Self(rawValue: 3)
}

#endif
