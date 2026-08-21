#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Linux_Standard_Core
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
        internal import Linux_Kernel_Shims
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Linux.Kernel.Copy {

        public enum Clone: Sendable {}
    }

    extension Linux.Kernel.Copy.Clone {

        internal static func perform(
            fromFd sourceFd: Int32,
            toFd destinationFd: Int32
        ) throws(Linux.Kernel.Copy.Error) {
            let result = swift_ficlone(destinationFd, sourceFd)
            guard result == 0 else {
                throw Linux.Kernel.Copy.Error(posixErrno: errno)
            }
        }

        public static func perform(
            from source: borrowing ISO_9945.Kernel.Descriptor,
            to destination: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Linux.Kernel.Copy.Error) {
            try perform(fromFd: source._rawValue, toFd: destination._rawValue)
        }
    }

#endif
