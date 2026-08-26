#if os(Linux)
    public import Linux_Standard_Core
    public import Error

    extension Linux.Kernel.Event {

        public struct Counter: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt64

            @inlinable
            public init(rawValue: UInt64) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.Event.Counter {

        @inlinable
        public init(_ value: UInt64) {
            self.rawValue = value
        }

        @inlinable
        public init(initval: UInt32) {
            self.rawValue = UInt64(initval)
        }

        public static let zero = Self(rawValue: 0)

        public static let one = Self(rawValue: 1)

        @inlinable
        public var isZero: Bool {
            rawValue == 0
        }
    }

    extension Linux.Kernel.Event.Counter: Comparable {
        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    extension UInt32 {

        @inlinable
        public init(_ counter: Linux.Kernel.Event.Counter) {
            self = UInt32(clamping: counter.rawValue)
        }
    }

    extension Linux.Kernel.Event.Counter: ExpressibleByIntegerLiteral {
        @inlinable
        public init(integerLiteral value: UInt64) {
            self.rawValue = value
        }
    }

    extension Linux.Kernel.Event.Counter: CustomStringConvertible {
        public var description: Swift.String {
            "\(rawValue)"
        }
    }

#endif
