public import Linux_Standard_Core

extension Linux.Kernel.Event {

    public struct Interest: OptionSet, Sendable, Hashable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

extension Linux.Kernel.Event.Interest {

    public static let read = Self(rawValue: 1 << 0)

    public static let write = Self(rawValue: 1 << 1)

    public static let priority = Self(rawValue: 1 << 2)
}
