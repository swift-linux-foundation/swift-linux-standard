#if os(Linux)
    import Testing

    import Error
    import Memory
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Uring.Submission.Queue {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Uring.Submission.Queue.Test.Unit {
        @Test
        func `Queue namespace exists`() {
            _ = Kernel.IO.Uring.Submission.Queue.self
        }

        @Test
        func `Queue is an enum`() {
            let _: Kernel.IO.Uring.Submission.Queue.Type = Kernel.IO.Uring.Submission.Queue.self
        }
    }

    extension Kernel.IO.Uring.Submission.Queue.Test.Unit {
        @Test
        func `Queue.Entry type exists`() {
            let _: Kernel.IO.Uring.Submission.Queue.Entry.Type = Kernel.IO.Uring.Submission.Queue
                .Entry.self
        }

        @Test
        func `Queue.Offsets type exists`() {
            let _: Kernel.IO.Uring.Submission.Queue.Offsets.Type = Kernel.IO.Uring.Submission.Queue
                .Offsets.self
        }
    }
#endif
