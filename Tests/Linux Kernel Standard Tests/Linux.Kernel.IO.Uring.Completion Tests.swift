#if os(Linux)
    import Testing

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Uring.Completion {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Uring.Completion.Test.Unit {
        @Test
        func `Completion namespace exists`() {
            _ = Kernel.IO.Uring.Completion.self
        }

        @Test
        func `Completion is an enum`() {
            let _: Kernel.IO.Uring.Completion.Type = Kernel.IO.Uring.Completion.self
        }
    }

    extension Kernel.IO.Uring.Completion.Test.Unit {
        @Test
        func `Completion.Queue type exists`() {
            let _: Kernel.IO.Uring.Completion.Queue.Type = Kernel.IO.Uring.Completion.Queue.self
        }
    }
#endif
