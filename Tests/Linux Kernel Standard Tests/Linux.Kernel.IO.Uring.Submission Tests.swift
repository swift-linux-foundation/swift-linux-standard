#if os(Linux)
    import Testing

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Uring.Submission {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Uring.Submission.Test.Unit {
        @Test
        func `Submission namespace exists`() {
            _ = Kernel.IO.Uring.Submission.self
        }

        @Test
        func `Submission is an enum`() {
            let _: Kernel.IO.Uring.Submission.Type = Kernel.IO.Uring.Submission.self
        }
    }

    extension Kernel.IO.Uring.Submission.Test.Unit {
        @Test
        func `Submission.Queue type exists`() {
            let _: Kernel.IO.Uring.Submission.Queue.Type = Kernel.IO.Uring.Submission.Queue.self
        }
    }
#endif
