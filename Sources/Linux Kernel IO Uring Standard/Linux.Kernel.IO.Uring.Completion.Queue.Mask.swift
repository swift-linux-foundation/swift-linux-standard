#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Completion.Queue {

        public struct Mask: Sendable, Equatable {
            @usableFromInline
            let rawValue: UInt32

            @inlinable
            package init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            @inlinable
            public func slot(for counter: UInt32) -> Int {
                Int(counter & rawValue)
            }
        }
    }

#endif
