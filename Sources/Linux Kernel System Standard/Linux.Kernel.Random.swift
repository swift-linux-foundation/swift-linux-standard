#if os(Linux) || os(Android) || os(OpenBSD)

    public import Random_Primitives

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

        public static func getrandom(_ span: inout MutableSpan<UInt8>) throws(Random.Error) {
            try unsafe span.withUnsafeMutableBytes {
                (buffer: UnsafeMutableRawBufferPointer) throws(Random.Error) in
                try unsafe getrandom(buffer)
            }
        }

        @unsafe
        public static func getrandom(_ buffer: UnsafeMutableRawBufferPointer) throws(Random.Error) {
            guard let base = buffer.baseAddress else { return }
            let total = buffer.count
            guard total > 0 else { return }

            var filled = 0
            while filled < total {
                let result = unsafe swift_getrandom(
                    unsafe base.advanced(by: filled),
                    total - filled,
                    0
                )

                if result > 0 {
                    filled += Int(result)
                    continue
                }

                if result == -1 {
                    if errno == EINTR {
                        continue
                    }
                    if errno == EAGAIN {
                        throw .entropyNotReady
                    }
                    throw .systemError(errno)
                }

                throw .systemError(0)
            }
        }

        @unsafe
        public static func getrandom(
            _ buffer: UnsafeMutableBufferPointer<UInt8>
        ) throws(Random.Error) {
            try unsafe getrandom(UnsafeMutableRawBufferPointer(buffer))
        }
    }

#endif
