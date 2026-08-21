#if os(Linux) || os(Android) || os(OpenBSD)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_Thread

    internal import Linux_Kernel_Shims

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #elseif canImport(Bionic)
        internal import Bionic
    #endif

    extension ISO_9945.Kernel.Thread {

        public struct ID: Hashable, Sendable, RawRepresentable, CustomStringConvertible {

            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }

            public var description: String { "tid(\(rawValue))" }
        }
    }

    extension ISO_9945.Kernel.Thread.ID {

        public static var current: Self {
            .init(rawValue: Int32(unsafe swift_gettid()))
        }
    }

#endif
