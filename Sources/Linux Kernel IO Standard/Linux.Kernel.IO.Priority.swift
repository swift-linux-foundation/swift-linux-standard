#if os(Linux)

    public import Linux_Standard_Core
    public import ISO_9945_Core
    extension Linux.Kernel.IO {

        public struct Priority: RawRepresentable, Sendable, Equatable, Hashable, Comparable {
            public let rawValue: UInt16

            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Priority {

        public init(_ value: UInt16) {
            self.rawValue = value
        }

        public static let `default` = Self(0)

        public static let normal = Self(0)
    }

    extension Linux.Kernel.IO.Priority {
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    extension Linux.Kernel.IO.Priority: ExpressibleByIntegerLiteral {
        public init(integerLiteral value: UInt16) {
            self.rawValue = value
        }
    }

    extension Linux.Kernel.IO.Priority: CustomStringConvertible {
        public var description: Swift::String {
            "\(rawValue)"
        }
    }

#endif
