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

        public enum Range: Sendable {}
    }

    extension Linux.Kernel.Copy.Range {

        internal static func copy(
            fromFd sourceFd: Int32,
            sourceOffset: inout ISO_9945.Kernel.File.Offset,
            toFd destinationFd: Int32,
            destOffset: inout ISO_9945.Kernel.File.Offset,
            length: ISO_9945.Kernel.File.Size
        ) throws(Linux.Kernel.Copy.Error) -> ISO_9945.Kernel.File.Size {
            var srcOff = off_t(sourceOffset.underlying)
            var dstOff = off_t(destOffset.underlying)

            let result = Int(
                swift_copy_file_range(
                    sourceFd,
                    &srcOff,
                    destinationFd,
                    &dstOff,
                    size_t(Int(length)),
                    0
                )
            )

            guard result >= 0 else {
                throw Linux.Kernel.Copy.Error(posixErrno: errno)
            }

            sourceOffset = ISO_9945.Kernel.File.Offset(Int64(srcOff))
            destOffset = ISO_9945.Kernel.File.Offset(Int64(dstOff))
            return ISO_9945.Kernel.File.Size(Int64(result))
        }

        public static func copy(
            from source: borrowing ISO_9945.Kernel.Descriptor,
            sourceOffset: inout ISO_9945.Kernel.File.Offset,
            to destination: borrowing ISO_9945.Kernel.Descriptor,
            destOffset: inout ISO_9945.Kernel.File.Offset,
            length: ISO_9945.Kernel.File.Size
        ) throws(Linux.Kernel.Copy.Error) -> ISO_9945.Kernel.File.Size {
            try copy(
                fromFd: source._rawValue,
                sourceOffset: &sourceOffset,
                toFd: destination._rawValue,
                destOffset: &destOffset,
                length: length
            )
        }
    }

#endif
