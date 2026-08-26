#if os(Linux)

    public import ISO_9945_Core
    public import Error
    public import Memory
    public import Path

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.Pipe {

        public struct Splice: Sendable {

            public struct Options: OptionSet, Sendable {
                public let rawValue: UInt32

                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                public static let move = Self(rawValue: UInt32(SPLICE_F_MOVE))

                public static let nonblock = Self(rawValue: UInt32(SPLICE_F_NONBLOCK))

                public static let more = Self(rawValue: UInt32(SPLICE_F_MORE))
            }
        }
    }

#endif
