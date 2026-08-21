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

    internal import Linux_Kernel_Shims

    extension ISO_9945.Kernel.File.Rename {

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
        ) throws(Error) {
            try unsafe renameat2(
                oldDirFD: AT_FDCWD,
                oldPath: oldPath,
                newDirFD: AT_FDCWD,
                newPath: newPath,
                flags: .noreplace
            )
        }

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
