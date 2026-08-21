#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public enum Submission {}
    }

    extension ISO_9945.Kernel.IO.Uring.Submission {

        public typealias Count = Tagged<ISO_9945.Kernel.IO.Uring.Submission, Cardinal>
    }

#endif
