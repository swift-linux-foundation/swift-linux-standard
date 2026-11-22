#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Register {
        public struct Opcode: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Opcode {
        public static let useRegisteredRing = Self(rawValue: 1 << 31)
    }

    extension Linux.Kernel.IO.Uring.Register {
        public struct Resource {
        }
    }

    extension Linux.Kernel.IO.Uring.Register.Resource {
        public static let sparse: UInt32 = 1
    }

#endif
