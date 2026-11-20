#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Opcode.Ring.Command {

        public struct Options: OptionSet, Sendable {
            public let rawValue: UInt32

            @inlinable
            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Opcode.Ring.Command.Options {

        public static let fixed = Self(rawValue: 1 << 0)
    }

#endif
