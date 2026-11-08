#if os(Linux)
    public import Linux_Standard_Core
    import Error

    extension Linux.Kernel.Event.Descriptor {
        public struct Flags: Sendable, Equatable, Hashable {
            public let rawValue: Int32

            @inlinable
            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.Event.Descriptor.Flags {
        public static let none = Self(rawValue: 0)

        @inlinable
        public static func | (lhs: Self, rhs: Self) -> Self {
            Self(rawValue: lhs.rawValue | rhs.rawValue)
        }
    }

#endif
