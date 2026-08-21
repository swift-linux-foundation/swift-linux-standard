#if os(Linux)
    public import Linux_Standard_Core
    public import Error_Primitives

    extension Linux.Kernel.Event.Descriptor {

        public struct Flags: Sendable, Equatable, Hashable {
            public let rawValue: Int32

            @inlinable
            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }

            public static let none = Flags(rawValue: 0)

            @inlinable
            public static func | (lhs: Flags, rhs: Flags) -> Flags {
                Flags(rawValue: lhs.rawValue | rhs.rawValue)
            }
        }
    }

#endif
