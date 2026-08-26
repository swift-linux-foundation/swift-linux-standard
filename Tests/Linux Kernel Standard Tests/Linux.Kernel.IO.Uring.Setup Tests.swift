#if os(Linux)
    import Testing

    import Error
    import Memory
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Uring.Setup {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Uring.Setup.Test.Unit {
        @Test
        func `Setup namespace exists`() {
            _ = Kernel.IO.Uring.Setup.self
        }

        @Test
        func `Setup is an enum`() {
            let _: Kernel.IO.Uring.Setup.Type = Kernel.IO.Uring.Setup.self
        }
    }

    extension Kernel.IO.Uring.Setup.Test.Unit {
        @Test
        func `Setup.Options type exists`() {
            let _: Kernel.IO.Uring.Setup.Options.Type = Kernel.IO.Uring.Setup.Options.self
        }
    }
#endif
