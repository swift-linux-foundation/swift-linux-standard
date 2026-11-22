#if os(Linux)

    public import Linux_Standard_Core
    import ISO_9945_Core
    extension Linux.Kernel.Futex.Wait {

        public struct Entry: Sendable, Equatable, Hashable {

            public var value: UInt64

            public var address: UInt64

            public var flags: UInt32

            internal var _reserved: UInt32

            public init(value: UInt64, address: UInt64, flags: UInt32) {
                self.value = value
                self.address = address
                self.flags = flags
                self._reserved = 0
            }
        }
    }

#endif
