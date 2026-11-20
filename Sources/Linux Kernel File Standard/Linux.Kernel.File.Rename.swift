#if os(Linux)

    public import Linux_Standard_Core
    public import ISO_9945_Core
    import ISO_9945_Kernel_File
    import Error
    import Memory
    import Path

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    internal import Linux_Kernel_Shims

    extension Linux.Kernel.File {

        public enum Rename: Sendable {}
    }

    extension Linux.Kernel.File.Rename {

        @unsafe
        public static func renameat2(
            oldDirFD: Int32,
            oldPath: UnsafePointer<CChar>,
            newDirFD: Int32,
            newPath: UnsafePointer<CChar>,
            flags: Options
        ) throws(ISO_9945.Kernel.File.Rename.Error) {
            let result = unsafe swift_renameat2(
                oldDirFD,
                oldPath,
                newDirFD,
                newPath,
                flags.rawValue
            )

            guard result == 0 else {
                let code = Error::Error.Code.posix(errno)
                switch code.posix {
                case EEXIST:
                    throw .exists

                case ENOSYS, EINVAL:

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

        @unsafe
        public static func noClobber(
            from oldPath: UnsafePointer<CChar>,
            to newPath: UnsafePointer<CChar>
        ) throws(ISO_9945.Kernel.File.Rename.Error) {
            try unsafe renameat2(
                oldDirFD: AT_FDCWD,
                oldPath: oldPath,
                newDirFD: AT_FDCWD,
                newPath: newPath,
                flags: .noreplace
            )
        }

        public static func noClobber(
            from oldPath: borrowing Path.Borrowed,
            to newPath: borrowing Path.Borrowed
        ) throws(ISO_9945.Kernel.File.Rename.Error) {
            try unsafe oldPath.withUnsafePointer { oldPtr throws(ISO_9945.Kernel.File.Rename.Error) in
                try unsafe newPath.withUnsafePointer { newPtr throws(ISO_9945.Kernel.File.Rename.Error) in
                    try unsafe noClobber(
                        from: UnsafeRawPointer(oldPtr).assumingMemoryBound(to: CChar.self),
                        to: UnsafeRawPointer(newPtr).assumingMemoryBound(to: CChar.self)
                    )
                }
            }
        }

        @unsafe
        public static func exchange(
            _ path1: UnsafePointer<CChar>,
            _ path2: UnsafePointer<CChar>
        ) throws(ISO_9945.Kernel.File.Rename.Error) {
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
