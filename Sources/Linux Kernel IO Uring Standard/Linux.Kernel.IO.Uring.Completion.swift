#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public enum Completion {}
    }

    extension ISO_9945.Kernel.IO.Uring.Completion {

        public typealias Count = Tagged<ISO_9945.Kernel.IO.Uring.Completion, Cardinal>
    }

#endif
