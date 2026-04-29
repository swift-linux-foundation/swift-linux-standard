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

    extension Kernel.IO.Uring.Personality {
        enum Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Personality.Test.Unit {
        @Test
        func `Personality namespace exists`() {
            let _: Kernel.IO.Uring.Personality.Type = Kernel.IO.Uring.Personality.self
        }

        @Test
        func `Personality is an enum`() {
            _ = Kernel.IO.Uring.Personality.self
        }

        @Test
        func `ID type exists`() {
            let _: Kernel.IO.Uring.Personality.ID.Type = Kernel.IO.Uring.Personality.ID.self
        }

        @Test
        func `ID literal construction`() {
            let id: Kernel.IO.Uring.Personality.ID = 42
            #expect(id.rawValue == 42)
        }

        @Test
        func `ID.none constant has rawValue 0`() {
            let none = Kernel.IO.Uring.Personality.ID.none
            #expect(none.rawValue == 0)
        }

        @Test
        func `ID rawValue access`() {
            let id: Kernel.IO.Uring.Personality.ID = 7
            #expect(id.rawValue == 7)
        }

        @Test
        func `ID is Sendable`() {
            let id: any Sendable = Kernel.IO.Uring.Personality.ID.none
            #expect(id is Kernel.IO.Uring.Personality.ID)
        }

        @Test
        func `ID is Equatable`() {
            let a: Kernel.IO.Uring.Personality.ID = 10
            let b: Kernel.IO.Uring.Personality.ID = 10
            let c: Kernel.IO.Uring.Personality.ID = 20
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `ID is Hashable`() {
            var set = Set<Kernel.IO.Uring.Personality.ID>()
            set.insert(.none)
            let one: Kernel.IO.Uring.Personality.ID = 1
            set.insert(one)
            set.insert(.none)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Personality.Test.`Edge Case` {
        @Test
        func `ID UInt16.max value`() {
            let id = Kernel.IO.Uring.Personality.ID(__unchecked: (), UInt16.max)
            #expect(id.rawValue == UInt16.max)
        }

        @Test
        func `ID rawValue roundtrip`() {
            for value: UInt16 in [0, 1, 100, UInt16.max] {
                let id = Kernel.IO.Uring.Personality.ID(__unchecked: (), value)
                #expect(id.rawValue == value)
            }
        }
    }
#endif
