#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Params {

        public struct Submission: Sendable, Equatable {

            public var thread: Thread

            public init(thread: Thread = Thread()) {
                self.thread = thread
            }
        }
    }

#endif
