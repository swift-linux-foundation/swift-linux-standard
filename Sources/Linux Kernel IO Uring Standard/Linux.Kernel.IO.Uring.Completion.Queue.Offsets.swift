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

    extension ISO_9945.Kernel.IO.Uring.Completion.Queue {

        public struct Offsets: Sendable, Equatable {

            public let head: Memory.Address.Offset

            public let tail: Memory.Address.Offset

            public let ringMask: Memory.Address.Offset

            public let ringEntries: Memory.Address.Offset

            public let overflow: Memory.Address.Offset

            public let cqes: Memory.Address.Offset

            public let flags: Memory.Address.Offset

            internal init() {
                self.head = .zero
                self.tail = .zero
                self.ringMask = .zero
                self.ringEntries = .zero
                self.overflow = .zero
                self.cqes = .zero
                self.flags = .zero
            }

            internal init(_ off: io_cqring_offsets) {
                self.head = Memory.Address.Offset(off.head)
                self.tail = Memory.Address.Offset(off.tail)
                self.ringMask = Memory.Address.Offset(off.ring_mask)
                self.ringEntries = Memory.Address.Offset(off.ring_entries)
                self.overflow = Memory.Address.Offset(off.overflow)
                self.cqes = Memory.Address.Offset(off.cqes)
                self.flags = Memory.Address.Offset(off.flags)
            }
        }
    }

#endif
