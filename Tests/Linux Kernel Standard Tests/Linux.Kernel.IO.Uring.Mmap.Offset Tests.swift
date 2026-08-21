#if os(Linux)
    import Testing

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Uring.Mmap.Offset {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Uring.Mmap.Offset.Test.Unit {
        @Test
        func `Mmap.Offset namespace exists`() {
            _ = Kernel.IO.Uring.Mmap.Offset.self
        }

        @Test
        func `Mmap.Offset is an enum`() {
            let _: Kernel.IO.Uring.Mmap.Offset.Type = Kernel.IO.Uring.Mmap.Offset.self
        }
    }

    extension Kernel.IO.Uring.Mmap.Offset.Test.Unit {
        @Test
        func `sqRing has value 0`() {
            #expect(Kernel.IO.Uring.Mmap.Offset.sqRing == 0)
        }

        @Test
        func `cqRing has value 0x8000000`() {
            #expect(Kernel.IO.Uring.Mmap.Offset.cqRing == 0x8000000)
        }

        @Test
        func `sqes has value 0x10000000`() {
            #expect(Kernel.IO.Uring.Mmap.Offset.sqes == 0x1000_0000)
        }
    }

    extension Kernel.IO.Uring.Mmap.Offset.Test.EdgeCase {
        @Test
        func `offsets are distinct`() {
            let offsets: [Int64] = [
                Kernel.IO.Uring.Mmap.Offset.sqRing,
                Kernel.IO.Uring.Mmap.Offset.cqRing,
                Kernel.IO.Uring.Mmap.Offset.sqes,
            ]

            for i in 0..<offsets.count {
                for j in (i + 1)..<offsets.count {
                    #expect(offsets[i] != offsets[j])
                }
            }
        }

        @Test
        func `offsets are page-aligned`() {

            #expect(Kernel.IO.Uring.Mmap.Offset.cqRing % 4096 == 0)
            #expect(Kernel.IO.Uring.Mmap.Offset.sqes % 4096 == 0)
        }

        @Test
        func `sqRing is zero`() {
            #expect(Kernel.IO.Uring.Mmap.Offset.sqRing == 0)
        }
    }
#endif
