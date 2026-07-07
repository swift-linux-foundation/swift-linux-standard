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
    @testable import Linux_Kernel_Event_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.Event.Poll.Create.Flags {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.Event.Poll.Create.Flags.Test.Unit {
        @Test
        func `init with rawValue stores value`() {
            let flags = Kernel.Event.Poll.Create.Flags(rawValue: 42)
            #expect(flags.rawValue == 42)
        }

        @Test
        func `none has rawValue of 0`() {
            #expect(Kernel.Event.Poll.Create.Flags.none.rawValue == 0)
        }

        @Test
        func `cloexec has non-zero rawValue`() {
            #expect(Kernel.Event.Poll.Create.Flags.cloexec.rawValue != 0)
        }

        @Test
        func `flags can be combined with union`() {
            let combined = Kernel.Event.Poll.Create.Flags.cloexec.union(.none)
            #expect(combined.rawValue == Kernel.Event.Poll.Create.Flags.cloexec.rawValue)
        }

        @Test
        func `rawValue roundtrip preserves value`() {
            let original: Int32 = 0x7FFF_FFFF
            let flags = Kernel.Event.Poll.Create.Flags(rawValue: original)
            #expect(flags.rawValue == original)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Event.Poll.Create.Flags.Test.Unit {
        @Test
        func `Create.Flags is Sendable`() {
            let flags: any Sendable = Kernel.Event.Poll.Create.Flags.cloexec
            #expect(flags is Kernel.Event.Poll.Create.Flags)
        }

        @Test
        func `Create.Flags is Equatable`() {
            let a = Kernel.Event.Poll.Create.Flags.cloexec
            let b = Kernel.Event.Poll.Create.Flags.cloexec
            let c = Kernel.Event.Poll.Create.Flags.none
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Create.Flags is Hashable`() {
            var set = Set<Kernel.Event.Poll.Create.Flags>()
            set.insert(.cloexec)
            set.insert(.none)
            set.insert(.cloexec)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Event.Poll.Create.Flags.Test.EdgeCase {
        @Test
        func `combining same flag is idempotent`() {
            let combined: Kernel.Event.Poll.Create.Flags = [.cloexec, .cloexec]
            #expect(combined == .cloexec)
        }

        @Test
        func `combining with none is identity`() {
            let combined = Kernel.Event.Poll.Create.Flags.cloexec.union(.none)
            #expect(combined == .cloexec)
        }

        @Test
        func `none combined with none is none`() {
            let combined = Kernel.Event.Poll.Create.Flags.none.union(.none)
            #expect(combined == .none)
        }
    }
#endif
