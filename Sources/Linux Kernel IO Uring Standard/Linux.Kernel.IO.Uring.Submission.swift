#if os(Linux)

    public import Linux_Standard_Core
    public import Linux_Kernel_IO_Standard
    public import ISO_9945_Core
    extension Linux.Kernel.IO.Uring {

        public enum Submission {}
    }

    extension Linux.Kernel.IO.Uring.Submission {

        public typealias Count = Tagged<Linux.Kernel.IO.Uring.Submission, Cardinal>
    }

#endif
