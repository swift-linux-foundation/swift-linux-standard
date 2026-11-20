public import Linux_Standard_Core

extension Linux.Kernel {

    public enum Pipe: Sendable {}
}

#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    import Error
    public import Pair

    #if canImport(Glibc)
        internal import Glibc
        internal import Linux_Kernel_Shims
    #elseif canImport(Musl)
        internal import Musl
        internal import Linux_Kernel_Shims
    #endif

    extension Linux.Kernel.Pipe {
        internal static func pipe2(
            flags: Options
        ) throws(ISO_9945.Kernel.Pipe.Error) -> (read: Int32, write: Int32) {
            var fds: (Int32, Int32) = (0, 0)

            let result = withUnsafeMutablePointer(to: &fds) { ptr in
                unsafe ptr.withMemoryRebound(to: Int32.self, capacity: 2) { fdPtr in
                    unsafe swift_pipe2(fdPtr, flags.rawValue)
                }
            }

            guard result == 0 else {
                throw .platform(Error::Error(code: .posix(errno)))
            }

            return (read: fds.0, write: fds.1)
        }

        public static func pipe2(
            flags: Options
        ) throws(ISO_9945.Kernel.Pipe.Error) -> Pair<ISO_9945.Kernel.Descriptor, ISO_9945.Kernel.Descriptor> {
            let raw = try pipe2(flags: flags) as (read: Int32, write: Int32)
            return Pair(
                ISO_9945.Kernel.Descriptor(_rawValue: raw.read),
                ISO_9945.Kernel.Descriptor(_rawValue: raw.write)
            )
        }
    }

#endif
