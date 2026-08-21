#if os(Linux)

    public import ISO_9945_Core
    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.IO.Uring.File {

        public enum Allocate: Sendable {
            public enum Mode: Sendable, Hashable {

                case allocate(keepSize: Bool = false)

                case punch

                case collapse

                case zero(keepSize: Bool = false)

                case insert

                case unshare
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.File.Allocate.Mode {

        @usableFromInline
        var rawBits: Int32 {
            switch self {
            case .allocate(let keepSize):
                keepSize ? FALLOC_FL_KEEP_SIZE : 0

            case .punch:
                FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE

            case .collapse:
                FALLOC_FL_COLLAPSE_RANGE

            case .zero(let keepSize):
                FALLOC_FL_ZERO_RANGE | (keepSize ? FALLOC_FL_KEEP_SIZE : 0)

            case .insert:
                FALLOC_FL_INSERT_RANGE

            case .unshare:
                FALLOC_FL_UNSHARE_RANGE
            }
        }
    }

#endif
