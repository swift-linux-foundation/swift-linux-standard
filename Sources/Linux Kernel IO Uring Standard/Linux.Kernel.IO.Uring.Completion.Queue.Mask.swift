#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Completion.Queue {
        public struct Mask: Sendable, Equatable {
            @usableFromInline
            let rawValue: UInt32

            @inlinable
            package init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Completion.Queue.Mask {
        @inlinable
        public func slot(for counter: UInt32) -> Int {
            Int(counter & rawValue)
        }
    }

#endif
