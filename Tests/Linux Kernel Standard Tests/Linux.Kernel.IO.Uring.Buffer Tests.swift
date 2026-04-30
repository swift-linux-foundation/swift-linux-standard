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

    extension Kernel.IO.Uring.Buffer {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Buffer.Test.Unit {
        @Test
        func `Buffer namespace exists`() {
            _ = Kernel.IO.Uring.Buffer.self
        }

        @Test
        func `Buffer is an enum`() {
            let _: Kernel.IO.Uring.Buffer.Type = Kernel.IO.Uring.Buffer.self
        }
    }

    // MARK: - Index Tests

    extension Kernel.IO.Uring.Buffer.Test.Unit {
        @Test
        func `Index from rawValue`() {
            let index = Kernel.IO.Uring.Buffer.Index(rawValue: 5)
            #expect(index.rawValue == 5)
        }

        @Test
        func `Index from UInt16`() {
            let index = Kernel.IO.Uring.Buffer.Index(10)
            #expect(index.rawValue == 10)
        }

        @Test
        func `Index.first constant`() {
            #expect(Kernel.IO.Uring.Buffer.Index.first.rawValue == 0)
        }

        @Test
        func `Index integer literal`() {
            let index: Kernel.IO.Uring.Buffer.Index = 42
            #expect(index.rawValue == 42)
        }

        @Test
        func `Index description`() {
            let index = Kernel.IO.Uring.Buffer.Index(123)
            #expect(index.description == "123")
        }

        @Test
        func `Index is Sendable`() {
            let index: any Sendable = Kernel.IO.Uring.Buffer.Index(0)
            #expect(index is Kernel.IO.Uring.Buffer.Index)
        }

        @Test
        func `Index is Equatable`() {
            let a = Kernel.IO.Uring.Buffer.Index(5)
            let b = Kernel.IO.Uring.Buffer.Index(5)
            let c = Kernel.IO.Uring.Buffer.Index(10)
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Index is Hashable`() {
            var set = Set<Kernel.IO.Uring.Buffer.Index>()
            set.insert(.first)
            set.insert(Kernel.IO.Uring.Buffer.Index(1))
            set.insert(.first)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Group Tests

    extension Kernel.IO.Uring.Buffer.Test.Unit {
        @Test
        func `Group from rawValue`() {
            let group = Kernel.IO.Uring.Buffer.Group(rawValue: 5)
            #expect(group.rawValue == 5)
        }

        @Test
        func `Group from UInt16`() {
            let group = Kernel.IO.Uring.Buffer.Group(10)
            #expect(group.rawValue == 10)
        }

        @Test
        func `Group integer literal`() {
            let group: Kernel.IO.Uring.Buffer.Group = 42
            #expect(group.rawValue == 42)
        }

        @Test
        func `Group description`() {
            let group = Kernel.IO.Uring.Buffer.Group(123)
            #expect(group.description == "123")
        }

        @Test
        func `Group is Sendable`() {
            let group: any Sendable = Kernel.IO.Uring.Buffer.Group(0)
            #expect(group is Kernel.IO.Uring.Buffer.Group)
        }

        @Test
        func `Group is Equatable`() {
            let a = Kernel.IO.Uring.Buffer.Group(5)
            let b = Kernel.IO.Uring.Buffer.Group(5)
            let c = Kernel.IO.Uring.Buffer.Group(10)
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Group is Hashable`() {
            var set = Set<Kernel.IO.Uring.Buffer.Group>()
            set.insert(Kernel.IO.Uring.Buffer.Group(0))
            set.insert(Kernel.IO.Uring.Buffer.Group(1))
            set.insert(Kernel.IO.Uring.Buffer.Group(0))  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Buffer.Test.EdgeCase {
        @Test
        func `Index max value`() {
            let index = Kernel.IO.Uring.Buffer.Index(UInt16.max)
            #expect(index.rawValue == UInt16.max)
        }

        @Test
        func `Group max value`() {
            let group = Kernel.IO.Uring.Buffer.Group(UInt16.max)
            #expect(group.rawValue == UInt16.max)
        }
    }
#endif
