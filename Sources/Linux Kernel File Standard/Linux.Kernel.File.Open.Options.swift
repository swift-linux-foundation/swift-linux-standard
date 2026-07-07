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

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error_Primitives
    public import Memory_Primitives
    public import Path_Primitives

    #if canImport(Glibc)
        internal import CLinuxKernelShim
    #endif

    // MARK: - Linux-specific Open Options

    extension ISO_9945.Kernel.File.Open.Options {
        /// Requests direct I/O, bypassing page cache (O_DIRECT).
        ///
        /// Linux-specific. Not available on Darwin.
        public static let direct = Self(rawValue: O_DIRECT)
    }

#endif
