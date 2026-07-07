// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

    public import ISO_9945_Core
    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.IO.Uring.File {
        /// Extended attribute namespace — wraps xattr operations.
        public enum Xattr {}
    }

    extension ISO_9945.Kernel.IO.Uring.File.Xattr {
        /// How to handle an existing or absent attribute.
        ///
        /// The three dispositions are mutually exclusive:
        /// - `.createOrReplace`: Set regardless of existence (default).
        ///
        /// - `.createOnly`: Fail with `EEXIST` if the attribute already exists.
        ///
        /// - `.replaceOnly`: Fail with `ENODATA` if the attribute does not exist.
        public enum Disposition: Sendable, Hashable {
            /// Set the attribute, creating or replacing as needed.
            case createOrReplace

            /// Create the attribute. Fail if it already exists.
            case createOnly

            /// Replace the attribute. Fail if it does not exist.
            case replaceOnly
        }
    }

    extension ISO_9945.Kernel.IO.Uring.File.Xattr.Disposition {
        /// The raw XATTR_* flag for the kernel.
        @usableFromInline
        var rawBits: UInt32 {
            switch self {
            case .createOrReplace: 0
            case .createOnly: UInt32(XATTR_CREATE)
            case .replaceOnly: UInt32(XATTR_REPLACE)
            }
        }
    }

#endif
