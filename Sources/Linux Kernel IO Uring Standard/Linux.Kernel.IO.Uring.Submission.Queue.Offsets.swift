#if os(Linux)

    public import ISO_9945_Core
    public import Memory

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue {

        public struct Offsets: Sendable, Equatable {

            public let head: Memory.Address.Offset

            public let tail: Memory.Address.Offset

            public let ringMask: Memory.Address.Offset

            public let ringEntries: Memory.Address.Offset

            public let flags: Memory.Address.Offset

            public let dropped: Memory.Address.Offset

            public let array: Memory.Address.Offset

            internal init() {
                self.head = .zero
                self.tail = .zero
                self.ringMask = .zero
                self.ringEntries = .zero
                self.flags = .zero
                self.dropped = .zero
                self.array = .zero
            }

            internal init(_ off: io_sqring_offsets) {
                self.head = Memory.Address.Offset(off.head)
                self.tail = Memory.Address.Offset(off.tail)
                self.ringMask = Memory.Address.Offset(off.ring_mask)
                self.ringEntries = Memory.Address.Offset(off.ring_entries)
                self.flags = Memory.Address.Offset(off.flags)
                self.dropped = Memory.Address.Offset(off.dropped)
                self.array = Memory.Address.Offset(off.array)
            }
        }
    }

    extension Memory.Address.Offset {

        @inlinable
        package init(_ cOffset: UInt32) {
            self.init(_unchecked: Affine.Discrete.Vector(Int(cOffset)))
        }
    }

#endif
