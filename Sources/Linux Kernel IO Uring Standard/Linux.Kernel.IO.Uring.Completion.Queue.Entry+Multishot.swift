#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry {

        public var hasMore: Bool {
            flags.contains(.more)
        }
    }

#endif
