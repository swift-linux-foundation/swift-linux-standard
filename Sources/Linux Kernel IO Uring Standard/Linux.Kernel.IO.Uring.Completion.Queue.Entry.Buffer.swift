#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Completion.Queue.Entry {
        public var buffer: Buffer { Buffer(entry: self) }

        public struct Buffer: Sendable {
            let entry: Linux.Kernel.IO.Uring.Completion.Queue.Entry

            init(entry: Linux.Kernel.IO.Uring.Completion.Queue.Entry) {
                self.entry = entry
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Completion.Queue.Entry.Buffer {
        public var index: Linux.Kernel.IO.Uring.Buffer.Index? {
            guard entry.flags.contains(.buffer) else { return nil }
            return Linux.Kernel.IO.Uring.Buffer.Index(
                rawValue: UInt16(truncatingIfNeeded: entry.flags.rawValue >> 16)
            )
        }
    }

#endif
