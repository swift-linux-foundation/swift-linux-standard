#if os(Linux)
    import Testing

    import Error
    import Memory
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Uring.Submission.Queue.Entry.Options {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }
#endif
