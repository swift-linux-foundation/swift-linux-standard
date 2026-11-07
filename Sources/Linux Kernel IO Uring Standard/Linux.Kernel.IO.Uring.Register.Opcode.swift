#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Opcode: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {

        public static let useRegisteredRing = Self(rawValue: 1 << 31)
    }

    extension ISO_9945.Kernel.IO.Uring.Register {

        public struct Resource {

            public static let sparse: UInt32 = 1
        }
    }

#endif
