// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-standard open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    // MARK: - POSIX errno to Copy.Error Mapping

    extension ISO_9945.Kernel.Copy.Error {
        /// Creates a copy error from a POSIX errno value.
        internal init(posixErrno: Int32) {
            switch posixErrno {
            case EBADF:
                self = .invalidDescriptor
            case EXDEV:
                self = .crossDevice
            case ENOSPC:
                self = .noSpace
            case EIO:
                self = .io
            case EACCES, EPERM:
                self = .permissionDenied
            case ENOENT:
                self = .notFound
            case EEXIST:
                self = .exists
            case EINVAL, ENOTSUP:
                self = .unsupported
            default:
                self = .unsupported
            }
        }
    }

#endif
