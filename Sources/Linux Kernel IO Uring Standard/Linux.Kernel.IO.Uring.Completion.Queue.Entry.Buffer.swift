#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry {

        public var buffer: Buffer { Buffer(entry: self) }

        public struct Buffer: Sendable {
            let entry: ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry

            init(entry: ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry) {
                self.entry = entry
            }

            public var index: ISO_9945.Kernel.IO.Uring.Buffer.Index? {
                guard entry.flags.contains(.buffer) else { return nil }
                return ISO_9945.Kernel.IO.Uring.Buffer.Index(
                    rawValue: UInt16(truncatingIfNeeded: entry.flags.rawValue >> 16)
                )
            }
        }
    }

#endif
