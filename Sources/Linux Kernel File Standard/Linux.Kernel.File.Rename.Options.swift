#if os(Linux)

    public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error_Primitives
    public import Memory_Primitives
    public import Path_Primitives

    extension ISO_9945.Kernel.File.Rename {

        public struct Options: OptionSet, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let noreplace = Self(rawValue: 1)

            public static let exchange = Self(rawValue: 2)

            public static let whiteout = Self(rawValue: 4)
        }
    }

#endif
