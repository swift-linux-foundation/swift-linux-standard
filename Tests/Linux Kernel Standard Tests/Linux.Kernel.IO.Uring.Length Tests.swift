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
    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring {
        enum LengthTest {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.LengthTest.Unit {
        @Test
        func `Length from Int`() {
            let length = Kernel.IO.Uring.Length(1024)
            #expect(length.rawValue == 1024)
        }

        @Test
        func `Length from rawValue`() {
            let length = Kernel.IO.Uring.Length(__unchecked: (), 4096)
            #expect(length.rawValue == 4096)
        }

        @Test
        func `Length.zero constant`() {
            #expect(Kernel.IO.Uring.Length.zero.rawValue == 0)
        }

        @Test
        func `Length integer literal`() {
            let length: Kernel.IO.Uring.Length = 8192
            #expect(length.rawValue == 8192)
        }

        @Test
        func `Length is Sendable`() {
            let length: any Sendable = Kernel.IO.Uring.Length(1024)
            #expect(length is Kernel.IO.Uring.Length)
        }

        @Test
        func `Length is Equatable`() {
            let a = Kernel.IO.Uring.Length(1024)
            let b = Kernel.IO.Uring.Length(1024)
            let c = Kernel.IO.Uring.Length(2048)
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Length is Comparable`() {
            let small = Kernel.IO.Uring.Length(100)
            let large = Kernel.IO.Uring.Length(1000)
            #expect(small < large)
            #expect(large > small)
        }

        @Test
        func `Length rawValue access`() {
            let length = Kernel.IO.Uring.Length(512)
            #expect(length.rawValue == 512)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.LengthTest.`Edge Case` {
        @Test
        func `Length max UInt32 value`() {
            let length = Kernel.IO.Uring.Length(__unchecked: (), UInt32.max)
            #expect(length.rawValue == UInt32.max)
        }

        @Test
        func `Length zero comparison`() {
            let zero = Kernel.IO.Uring.Length.zero
            let nonZero = Kernel.IO.Uring.Length(1)
            #expect(zero < nonZero)
        }

        @Test
        func `Length clamping large Int values`() {
            let length = Kernel.IO.Uring.Length(Int(UInt32.max) + 1000)
            #expect(length.rawValue == UInt32.max)
        }

        @Test
        func `Length ordering`() {
            let lengths = [
                Kernel.IO.Uring.Length(100),
                Kernel.IO.Uring.Length(50),
                Kernel.IO.Uring.Length(200),
            ]
            let sorted = lengths.sorted()
            #expect(sorted[0].rawValue == 50)
            #expect(sorted[1].rawValue == 100)
            #expect(sorted[2].rawValue == 200)
        }
    }
#endif
