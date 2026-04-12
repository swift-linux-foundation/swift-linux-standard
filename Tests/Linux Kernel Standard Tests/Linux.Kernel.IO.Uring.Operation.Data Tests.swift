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
        @Test("Data literal construction")
        func literalConstruction() {
            let data: Kernel.IO.Uring.Operation.Data = 42
            #expect(data.rawValue == 42)
        }

        @Test("Data.zero constant")
        func zeroConstant() {
            let zero = Kernel.IO.Uring.Operation.Data.zero
            #expect(zero.rawValue == 0)
        }

        @Test("Data rawValue access")
        func rawValueAccess() {
            let data: Kernel.IO.Uring.Operation.Data = 99
            #expect(data.rawValue == 99)
        }

        @Test("Data from UnsafeRawPointer")
        func fromRawPointer() {
            var value: Int = 42
            withUnsafePointer(to: &value) { ptr in
                let rawPtr = unsafe UnsafeRawPointer(ptr)
                let data = unsafe Kernel.IO.Uring.Operation.Data(rawPtr)
                let expected = unsafe UInt64(UInt(bitPattern: ptr))
                #expect(data.rawValue == expected)
            }
        }

        @Test("Data from typed pointer")
        func fromTypedPointer() {
            var value: Int = 42
            withUnsafePointer(to: &value) { ptr in
                let data = unsafe Kernel.IO.Uring.Operation.Data(pointer: ptr)
                let expected = unsafe UInt64(UInt(bitPattern: ptr))
                #expect(data.rawValue == expected)
            }
        }

        @Test("Data from mutable typed pointer")
        func fromMutableTypedPointer() {
            var value: Int = 42
            withUnsafeMutablePointer(to: &value) { ptr in
                let data = unsafe Kernel.IO.Uring.Operation.Data(pointer: ptr)
                let expected = unsafe UInt64(UInt(bitPattern: ptr))
                #expect(data.rawValue == expected)
            }
        }

        @Test("Data is Sendable")
        func isSendable() {
            let data: any Sendable = Kernel.IO.Uring.Operation.Data.zero
            #expect(data is Kernel.IO.Uring.Operation.Data)
        }

        @Test("Data is Equatable")
        func isEquatable() {
            let a: Kernel.IO.Uring.Operation.Data = 100
            let b: Kernel.IO.Uring.Operation.Data = 100
            let c: Kernel.IO.Uring.Operation.Data = 200
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Data is Hashable")
        func isHashable() {
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
        @Test("Data UInt64.max value")
        func maxValue() {
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), UInt64.max)
            #expect(data.rawValue == UInt64.max)
        }

        @Test("Data Set insertion deduplication")
        func setDeduplication() {
            let a: Kernel.IO.Uring.Operation.Data = 42
            let b: Kernel.IO.Uring.Operation.Data = 42
            let c: Kernel.IO.Uring.Operation.Data = 99
            var set = Set<Kernel.IO.Uring.Operation.Data>()
            set.insert(a)
            set.insert(b)
            set.insert(c)
            #expect(set.count == 2)
        }

        @Test("Data rawValue roundtrip")
        func rawValueRoundtrip() {
            for value: UInt64 in [0, 1, 100, 0xDEAD_BEEF, UInt64.max] {
                let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), value)
                #expect(data.rawValue == value)
            }
        }
    }
#endif
