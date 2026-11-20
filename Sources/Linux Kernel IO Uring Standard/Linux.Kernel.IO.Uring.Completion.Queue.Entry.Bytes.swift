#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Completion.Queue.Entry {
        public var bytes: Bytes { Bytes(entry: self) }

        public struct Bytes: Sendable {
            let entry: Linux.Kernel.IO.Uring.Completion.Queue.Entry

            init(entry: Linux.Kernel.IO.Uring.Completion.Queue.Entry) {
                self.entry = entry
            }
        }
    }

    extension Linux.Kernel.IO.Uring.Completion.Queue.Entry.Bytes {
        public var transferred: Int? {
            entry.isSuccess ? Int(entry.res) : nil
        }
    }

#endif
