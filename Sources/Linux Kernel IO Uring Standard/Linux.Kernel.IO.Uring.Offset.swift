#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Dimension_Primitives

    public import Binary_Primitives

    extension ISO_9945.Kernel.IO.Uring {

        public typealias Offset = Coordinate.X<Space>.Value<UInt64>
    }

    extension ISO_9945.Kernel.IO.Uring.Offset {

        public static let zero: Self = .init(UInt64(0))

        public static let current = Self(UInt64.max)
    }

    extension ISO_9945.Kernel.IO.Uring.Offset {

        public init(_ fileOffset: ISO_9945.Kernel.File.Offset) {
            if fileOffset.underlying >= 0 {
                self.init(UInt64(fileOffset.underlying))
            } else {
                self = .current
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Offset: CustomStringConvertible {
        public var description: Swift.String {
            if self == .current {
                return "current"
            }
            return "\(underlying)"
        }
    }

#endif
