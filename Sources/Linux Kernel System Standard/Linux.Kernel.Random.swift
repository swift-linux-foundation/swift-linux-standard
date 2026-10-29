#if os(Linux) || os(Android) || os(OpenBSD)

    #if canImport(Glibc)
        internal import Glibc
        internal import Linux_Kernel_Shims
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Linux.Kernel {

        public enum Random: Sendable {}
    }

    extension Linux.Kernel.Random {

        /// One `getrandom(2)` call.
        ///
        /// - Returns: The number of bytes written, which may be fewer than `span.count`.
        public static func getrandom(_ span: inout MutableSpan<UInt8>) throws(Error) -> Int {
            try span.withUnsafeMutableBytes {
                (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
                try unsafe getrandom(buffer)
            }
        }

        /// One `getrandom(2)` call.
        ///
        /// - Returns: The number of bytes written, which may be fewer than `buffer.count`.
        @unsafe
        public static func getrandom(_ buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int {
            guard let base = buffer.baseAddress, buffer.count > 0 else { return 0 }
            let result = unsafe swift_getrandom(base, buffer.count, 0)
            guard result == -1 else { return Int(result) }
            switch errno {
            case EINTR: throw .interrupted
            case EAGAIN: throw .entropyNotReady
            case let code: throw .systemError(code)
            }
        }
    }

#endif
