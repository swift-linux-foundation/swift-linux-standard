#if os(Linux)

    extension Linux.Kernel {

        public enum Time: Sendable {}
    }

    extension Linux.Kernel.Time {

        public struct Specification: Sendable, Equatable, Hashable {

            public var seconds: Int64

            public var nanoseconds: Int64

            public init(seconds: Int64, nanoseconds: Int64) {
                self.seconds = seconds
                self.nanoseconds = nanoseconds
            }
        }
    }

#endif
