#if os(Linux)
    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif
    import Error
    import Testing

    @testable import Linux_Kernel_File_Standard

    extension Linux.Kernel.Copy.Error {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
        }
    }

    extension Linux.Kernel.Copy.Error.Test.Unit {
        @Test
        func `copy_file_range(2) and FICLONE errnos with a meaning keep their case`() {
            #expect(Linux.Kernel.Copy.Error(posixErrno: EBADF) == .invalidDescriptor)
            #expect(Linux.Kernel.Copy.Error(posixErrno: EXDEV) == .crossDevice)
            #expect(Linux.Kernel.Copy.Error(posixErrno: ENOSPC) == .noSpace)
            #expect(Linux.Kernel.Copy.Error(posixErrno: EIO) == .io)
            #expect(Linux.Kernel.Copy.Error(posixErrno: EACCES) == .permissionDenied)
            #expect(Linux.Kernel.Copy.Error(posixErrno: EPERM) == .permissionDenied)
            #expect(Linux.Kernel.Copy.Error(posixErrno: ENOENT) == .notFound)
            #expect(Linux.Kernel.Copy.Error(posixErrno: EEXIST) == .exists)
        }

        @Test
        func `copy_file_range(2) and FICLONE unsupported errnos report unsupported`() {
            #expect(Linux.Kernel.Copy.Error(posixErrno: EINVAL) == .unsupported)
            #expect(Linux.Kernel.Copy.Error(posixErrno: ENOTSUP) == .unsupported)
            #expect(Linux.Kernel.Copy.Error(posixErrno: EOPNOTSUPP) == .unsupported)
            #expect(Linux.Kernel.Copy.Error(posixErrno: ENOSYS) == .unsupported)
        }
    }

    extension Linux.Kernel.Copy.Error.Test.`Edge Case` {
        @Test
        func `copy_file_range(2) and FICLONE errnos without a case are not reported as unsupported`() {
            for errno in [EISDIR, EFBIG, EOVERFLOW, ETXTBSY, EROFS, ENOMEM] {
                #expect(Linux.Kernel.Copy.Error(posixErrno: errno) != .unsupported)
            }
        }
    }
#endif
