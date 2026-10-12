#if os(Linux)

    internal import Error
    public import Linux_Standard_Core
    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Linux.Kernel.Copy.Error {

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

            case EINVAL, ENOTSUP, EOPNOTSUPP, ENOSYS:
                self = .unsupported

            default:
                self = .platform(code: .posix(posixErrno))
            }
        }
    }

#endif
