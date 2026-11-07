#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry {

        public var bytes: Bytes { Bytes(entry: self) }

        public struct Bytes: Sendable {
            let entry: ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry

            init(entry: ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry) {
                self.entry = entry
            }

            public var transferred: Int? {
                entry.isSuccess ? Int(entry.res) : nil
            }
        }
    }

#endif
