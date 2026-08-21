#if os(Linux)
    import Testing

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Uring.Completion.Queue {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Uring.Completion.Queue.Test.Unit {
        @Test
        func `Queue namespace exists`() {
            _ = Kernel.IO.Uring.Completion.Queue.self
        }

        @Test
        func `Queue is an enum`() {
            let _: Kernel.IO.Uring.Completion.Queue.Type = Kernel.IO.Uring.Completion.Queue.self
        }
    }

    extension Kernel.IO.Uring.Completion.Queue.Test.Unit {
        @Test
        func `Queue.Entry type exists`() {
            let _: Kernel.IO.Uring.Completion.Queue.Entry.Type = Kernel.IO.Uring.Completion.Queue
                .Entry.self
        }

        @Test
        func `Queue.Offsets type exists`() {
            let _: Kernel.IO.Uring.Completion.Queue.Offsets.Type = Kernel.IO.Uring.Completion.Queue
                .Offsets.self
        }
    }
#endif
