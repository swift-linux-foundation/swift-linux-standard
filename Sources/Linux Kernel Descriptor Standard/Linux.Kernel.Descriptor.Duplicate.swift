#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import Error

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    internal import Linux_Kernel_Shims

    extension ISO_9945.Kernel.Descriptor.Duplicate {

        internal static func duplicate(
            sourceFd: Int32,
            destinationFd: Int32,
            flags: Options
        ) throws(Error) {
            let result = swift_dup3(sourceFd, destinationFd, flags.rawValue)

            guard result >= 0 else {
                let e = errno
                switch e {
                case EBADF:
                    throw .handle(.invalid)

                case EMFILE:
                    throw .tooManyOpen

                default:
                    throw .platform(Error.Error(code: .posix(e)))
                }
            }
        }

        public static func duplicate(
            source: borrowing ISO_9945.Kernel.Descriptor,
            destination: borrowing ISO_9945.Kernel.Descriptor,
            flags: Options
        ) throws(Error) {
            try duplicate(
                sourceFd: source._rawValue,
                destinationFd: destination._rawValue,
                flags: flags
            )
        }
    }

#endif
