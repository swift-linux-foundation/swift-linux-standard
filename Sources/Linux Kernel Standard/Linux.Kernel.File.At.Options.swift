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

#if os(Linux)

public import Kernel_File_Primitives
public import ISO_9945_Kernel

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.File.At.Options {
    /// Allow operations on empty path with fd (AT_EMPTY_PATH).
    ///
    /// Linux-specific extension to POSIX AT_* flags.
    public static let emptyPath = Self(rawValue: Int32(AT_EMPTY_PATH))
}

#endif
