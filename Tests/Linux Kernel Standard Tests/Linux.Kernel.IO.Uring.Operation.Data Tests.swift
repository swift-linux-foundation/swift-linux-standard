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

    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.Operation {
        enum DataTest {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Operation.DataTest.Unit {
        @Test
        func `Data literal construction`() {
            let data: Kernel.IO.Uring.Operation.Data = 42
            #expect(data.rawValue == 42)
        }

        @Test
        func `Data.zero constant`() {
            let zero = Kernel.IO.Uring.Operation.Data.zero
            #expect(zero.rawValue == 0)
        }

        @Test
        func `Data rawValue access`() {
            let data: Kernel.IO.Uring.Operation.Data = 99
            #expect(data.rawValue == 99)
        }

        @Test
        func `Data from UnsafeRawPointer`() {
            var value: Int = 42
            withUnsafePointer(to: &value) { ptr in
                let rawPtr = unsafe UnsafeRawPointer(ptr)
                let data = unsafe Kernel.IO.Uring.Operation.Data(rawPtr)
                let expected = unsafe UInt64(UInt(bitPattern: ptr))
                #expect(data.rawValue == expected)
            }
        }

        @Test
        func `Data from typed pointer`() {
            var value: Int = 42
            withUnsafePointer(to: &value) { ptr in
                let data = unsafe Kernel.IO.Uring.Operation.Data(pointer: ptr)
                let expected = unsafe UInt64(UInt(bitPattern: ptr))
                #expect(data.rawValue == expected)
            }
        }

        @Test
        func `Data from mutable typed pointer`() {
            var value: Int = 42
            withUnsafeMutablePointer(to: &value) { ptr in
                let data = unsafe Kernel.IO.Uring.Operation.Data(pointer: ptr)
                let expected = unsafe UInt64(UInt(bitPattern: ptr))
                #expect(data.rawValue == expected)
            }
        }

        @Test
        func `Data is Sendable`() {
            let data: any Sendable = Kernel.IO.Uring.Operation.Data.zero
            #expect(data is Kernel.IO.Uring.Operation.Data)
        }

        @Test
        func `Data is Equatable`() {
            let a: Kernel.IO.Uring.Operation.Data = 100
            let b: Kernel.IO.Uring.Operation.Data = 100
            let c: Kernel.IO.Uring.Operation.Data = 200
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Data is Hashable`() {
            var set = Set<Kernel.IO.Uring.Operation.Data>()
            set.insert(.zero)
            let one: Kernel.IO.Uring.Operation.Data = 1
            set.insert(one)
            set.insert(.zero)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Operation.DataTest.`Edge Case` {
        @Test
        func `Data UInt64.max value`() {
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), UInt64.max)
            #expect(data.rawValue == UInt64.max)
        }

        @Test
        func `Data Set insertion deduplication`() {
            let a: Kernel.IO.Uring.Operation.Data = 42
            let b: Kernel.IO.Uring.Operation.Data = 42
            let c: Kernel.IO.Uring.Operation.Data = 99
            var set = Set<Kernel.IO.Uring.Operation.Data>()
            set.insert(a)
            set.insert(b)
            set.insert(c)
            #expect(set.count == 2)
        }

        @Test
        func `Data rawValue roundtrip`() {
            for value: UInt64 in [0, 1, 100, 0xDEAD_BEEF, UInt64.max] {
                let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), value)
                #expect(data.rawValue == value)
            }
        }
    }
#endif
