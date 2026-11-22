#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Buffer {
        public struct Index: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt16

            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }

            public init(_ value: UInt16) {
                self.rawValue = value
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Buffer.Index {
        public static let first = Self(0)
    }

    extension Linux.Kernel.IO.Uring.Buffer.Index: ExpressibleByIntegerLiteral {
        public init(integerLiteral value: UInt16) {
            self.rawValue = value
        }
    }

    extension Linux.Kernel.IO.Uring.Buffer.Index: CustomStringConvertible {
        public var description: Swift::String {
            "\(rawValue)"
        }
    }

#endif
