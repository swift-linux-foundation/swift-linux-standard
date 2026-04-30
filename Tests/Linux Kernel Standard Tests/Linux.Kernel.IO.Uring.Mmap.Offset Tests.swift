// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)
import Testing
    import Kernel_Primitives_Test_Support

    import Kernel_IO_Primitives
    import Error_Primitives
    import Kernel_File_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    extension Kernel.IO.Uring.Mmap.Offset {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

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

    // MARK: - Constant Tests

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

    // MARK: - Edge Cases

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
            // cqRing and sqes should be page-aligned (multiple of common page sizes)
            #expect(Kernel.IO.Uring.Mmap.Offset.cqRing % 4096 == 0)
            #expect(Kernel.IO.Uring.Mmap.Offset.sqes % 4096 == 0)
        }

        @Test
        func `sqRing is zero`() {
            #expect(Kernel.IO.Uring.Mmap.Offset.sqRing == 0)
        }
    }
#endif
