#if os(Linux)
    import Testing

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Uring.Operation {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Uring.Operation.Test.Unit {
        @Test
        func `Operation namespace exists`() {
            _ = Kernel.IO.Uring.Operation.self
        }

        @Test
        func `Operation is an enum`() {
            let _: Kernel.IO.Uring.Operation.Type = Kernel.IO.Uring.Operation.self
        }
    }

    extension Kernel.IO.Uring.Operation.Test.Unit {
        @Test
        func `Operation.Data type exists`() {
            let _: Kernel.IO.Uring.Operation.Data.Type = Kernel.IO.Uring.Operation.Data.self
        }
    }
#endif
