#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Linux.Kernel.IO.Uring.File {

        public enum Xattr {}
    }

    extension Linux.Kernel.IO.Uring.File.Xattr {

        public enum Disposition: Sendable, Hashable {

            case createOrReplace

            case createOnly

            case replaceOnly
        }
    }

    extension Linux.Kernel.IO.Uring.File.Xattr.Disposition {

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
