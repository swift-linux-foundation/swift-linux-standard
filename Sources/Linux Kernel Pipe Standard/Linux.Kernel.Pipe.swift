#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import Error
    public import Pair

    #if canImport(Glibc)
        internal import Glibc
        internal import Linux_Kernel_Shims
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.Pipe {

        internal static func pipe2(
            flags: Options
        ) throws(Error) -> (read: Int32, write: Int32) {
            var fds: (Int32, Int32) = (0, 0)

            let result = withUnsafeMutablePointer(to: &fds) { ptr in
                ptr.withMemoryRebound(to: Int32.self, capacity: 2) { fdPtr in
                    swift_pipe2(fdPtr, flags.rawValue)
                }
            }

            guard result == 0 else {

                throw .platform(Error.Error(code: .posix(errno)))
            }

            return (read: fds.0, write: fds.1)
        }

        public static func pipe2(
            flags: Options
        ) throws(Error) -> Pair<ISO_9945.Kernel.Descriptor, ISO_9945.Kernel.Descriptor> {
            let raw = try pipe2(flags: flags) as (read: Int32, write: Int32)
            return unsafe Pair(
                ISO_9945.Kernel.Descriptor(_rawValue: raw.read),
                ISO_9945.Kernel.Descriptor(_rawValue: raw.write)
            )
        }

        public struct Options: OptionSet, Sendable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }

            public static let closeOnExec = Self(rawValue: O_CLOEXEC)

            public static let nonBlock = Self(rawValue: O_NONBLOCK)

            public static let direct = Self(rawValue: O_DIRECT)
        }
    }

#endif
