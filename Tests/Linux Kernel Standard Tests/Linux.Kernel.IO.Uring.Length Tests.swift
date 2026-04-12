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
    import Kernel_Primitives_Core
    import Kernel_IO_Primitives
    import Kernel_Descriptor_Primitives
    import Kernel_Error_Primitives
    import Kernel_File_Primitives
    import Kernel_Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

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
        @Test("Length from Int")
        func fromInt() {
            let length = Kernel.IO.Uring.Length(1024)
            #expect(length.rawValue == 1024)
        }

        @Test("Length from rawValue")
        func fromRawValue() {
            let length = Kernel.IO.Uring.Length(__unchecked: (), 4096)
            #expect(length.rawValue == 4096)
        }

        @Test("Length.zero constant")
        func zeroConstant() {
            #expect(Kernel.IO.Uring.Length.zero.rawValue == 0)
        }

        @Test("Length integer literal")
        func integerLiteral() {
            let length: Kernel.IO.Uring.Length = 8192
            #expect(length.rawValue == 8192)
        }

        @Test("Length is Sendable")
        func isSendable() {
            let length: any Sendable = Kernel.IO.Uring.Length(1024)
            #expect(length is Kernel.IO.Uring.Length)
        }

        @Test("Length is Equatable")
        func isEquatable() {
            let a = Kernel.IO.Uring.Length(1024)
            let b = Kernel.IO.Uring.Length(1024)
            let c = Kernel.IO.Uring.Length(2048)
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Length is Comparable")
        func isComparable() {
            let small = Kernel.IO.Uring.Length(100)
            let large = Kernel.IO.Uring.Length(1000)
            #expect(small < large)
            #expect(large > small)
        }

        @Test("Length rawValue access")
        func rawValueAccess() {
            let length = Kernel.IO.Uring.Length(512)
            #expect(length.rawValue == 512)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.LengthTest.`Edge Case` {
        @Test("Length max UInt32 value")
        func maxValue() {
            let length = Kernel.IO.Uring.Length(__unchecked: (), UInt32.max)
            #expect(length.rawValue == UInt32.max)
        }

        @Test("Length zero comparison")
        func zeroComparison() {
            let zero = Kernel.IO.Uring.Length.zero
            let nonZero = Kernel.IO.Uring.Length(1)
            #expect(zero < nonZero)
        }

        @Test("Length clamping large Int values")
        func clampsLargeValues() {
            let length = Kernel.IO.Uring.Length(Int(UInt32.max) + 1000)
            #expect(length.rawValue == UInt32.max)
        }

        @Test("Length ordering")
        func ordering() {
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
