#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Submission {

        public enum Queue {}
    }

#endif
