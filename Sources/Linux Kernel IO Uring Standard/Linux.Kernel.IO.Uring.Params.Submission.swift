#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    import ISO_9945_Core
    extension Linux.Kernel.IO.Uring.Params {

        public struct Submission: Sendable, Equatable {

            public var thread: Thread

            public init(thread: Thread = Thread()) {
                self.thread = thread
            }
        }
    }

#endif
