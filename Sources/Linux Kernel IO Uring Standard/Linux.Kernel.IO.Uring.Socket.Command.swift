#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Socket {

        public struct Command: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Socket.Command {

        public static let inputQueue = Self(rawValue: 0)

        public static let outputQueue = Self(rawValue: 1)

        public static let getOption = Self(rawValue: 2)

        public static let setOption = Self(rawValue: 3)
    }

#endif
