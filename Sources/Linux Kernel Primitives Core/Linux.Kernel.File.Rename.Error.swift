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

#if canImport(Glibc) || canImport(Musl)

    public import Kernel_Primitives

    extension Kernel.File.Rename {
        /// Errors from renameat2 operations.
        ///
        /// Low-level errors from the renameat2(2) syscall.
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// Destination already exists (RENAME_NOREPLACE was set).
            ///
            /// The rename was attempted with `.noreplace` flag but
            /// the destination path already exists.
            case exists

            /// Operation not supported.
            ///
            /// Either renameat2 syscall is not available (kernel < 3.15),
            /// or the filesystem doesn't support the requested flags.
            case notSupported

            /// Permission denied.
            ///
            /// The operation was rejected due to permissions.
            /// Contains the raw error code for diagnostics.
            case permission(Kernel.Error.Code)

            /// Platform-specific error.
            ///
            /// Contains the raw error code for diagnostics.
            case platform(Kernel.Error.Code)
        }
    }

    extension Kernel.File.Rename.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .exists:
                return "renameat2 failed: destination exists (RENAME_NOREPLACE)"
            case .notSupported:
                return "renameat2 not supported (old kernel or filesystem)"
            case .permission(let code):
                return "renameat2 permission denied (\(code))"
            case .platform(let code):
                return "renameat2 failed (\(code))"
            }
        }
    }

#endif
