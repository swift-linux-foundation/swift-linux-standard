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

// MARK: - Linux File At Flags

extension Kernel.File.At.Options {
    /// Do not follow symbolic links (AT_SYMLINK_NOFOLLOW).
    public static let noFollow = Options(rawValue: Int32(AT_SYMLINK_NOFOLLOW))

    /// Allow operations on empty path with fd (AT_EMPTY_PATH).
    public static let emptyPath = Options(rawValue: Int32(AT_EMPTY_PATH))

    /// Follow symbolic links (AT_SYMLINK_FOLLOW).
    public static let symlinkFollow = Options(rawValue: Int32(AT_SYMLINK_FOLLOW))

    /// Remove directory instead of file (AT_REMOVEDIR).
    public static let removeDirectory = Options(rawValue: Int32(AT_REMOVEDIR))
}

#endif
