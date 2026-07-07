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

#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error_Primitives
    public import Memory_Primitives
    public import Path_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    internal import CLinuxKernelShim

    extension ISO_9945.Kernel.File.Rename {
        /// Atomically renames a file with flags.
        ///
        /// Uses renameat2(2) to perform atomic rename operations with
        /// additional flags not available in the standard rename(2).
        ///
        /// - Parameters:
        ///   - oldDirFD: Directory fd for oldPath (AT_FDCWD for cwd).
        ///   - oldPath: Source path.
        ///   - newDirFD: Directory fd for newPath (AT_FDCWD for cwd).
        ///   - newPath: Destination path.
        ///   - flags: Rename flags controlling behavior.
        ///
        /// - Throws: `Error` if the rename fails.
        ///
        /// ## Blocking Behavior
        ///
        /// This method performs a blocking syscall but typically completes
        /// quickly. Safe to call from most contexts.
        ///
        /// ## Cancellation
        ///
        /// Not cancellable once the syscall begins. Check task cancellation
        /// before calling if cooperative cancellation is needed.
        @unsafe
        public static func renameat2(
            oldDirFD: Int32,
            oldPath: UnsafePointer<CChar>,
            newDirFD: Int32,
            newPath: UnsafePointer<CChar>,
            flags: Options
        ) throws(Error) {
            let result = unsafe swift_renameat2(
                oldDirFD,
                oldPath,
                newDirFD,
                newPath,
                flags.rawValue
            )

            guard result == 0 else {
                let code = Error_Primitives.Error.Code.posix(errno)
                switch code.posix {
                case EEXIST:
                    throw .exists
                case ENOSYS, EINVAL:
                    // ENOSYS: syscall not available (old kernel < 3.15)
                    // EINVAL: flags not supported by filesystem
                    throw .notSupported
                case EOPNOTSUPP, ENOTSUP:
                    throw .notSupported
                case EPERM, EACCES:
                    throw .permission(code)
                default:
                    throw .platform(code)
                }
            }
        }

        /// Atomically renames a file, failing if destination exists.
        ///
        /// Convenience wrapper that uses RENAME_NOREPLACE flag.
        ///
        /// - Parameters:
        ///   - oldPath: Source path.
        ///   - newPath: Destination path.
        ///
        /// - Throws: `Error.exists` if destination exists, other errors on failure.
        @unsafe
        public static func noClobber(
            from oldPath: UnsafePointer<CChar>,
            to newPath: UnsafePointer<CChar>
        ) throws(Error) {
            try unsafe renameat2(
                oldDirFD: AT_FDCWD,
                oldPath: oldPath,
                newDirFD: AT_FDCWD,
                newPath: newPath,
                flags: .noreplace
            )
        }

        /// Atomically exchanges two files.
        ///
        /// Convenience wrapper that uses RENAME_EXCHANGE flag.
        ///
        /// Both paths must exist.
        ///
        /// - Parameters:
        ///   - path1: First path.
        ///   - path2: Second path.
        ///
        /// - Throws: `Error` on failure.
        @unsafe
        public static func exchange(
            _ path1: UnsafePointer<CChar>,
            _ path2: UnsafePointer<CChar>
        ) throws(Error) {
            try unsafe renameat2(
                oldDirFD: AT_FDCWD,
                oldPath: path1,
                newDirFD: AT_FDCWD,
                newPath: path2,
                flags: .exchange
            )
        }
    }

#endif
