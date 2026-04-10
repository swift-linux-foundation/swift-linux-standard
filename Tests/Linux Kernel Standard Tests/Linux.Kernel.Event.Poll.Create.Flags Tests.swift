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

    import Kernel_Primitives_Core
    import Kernel_Event_Primitives
    import Kernel_IO_Primitives
    import Kernel_Descriptor_Primitives
    import Kernel_Error_Primitives
    import Kernel_File_Primitives
    import Kernel_Memory_Primitives
    @testable import Linux_Kernel_Standard

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
        @Test("init with rawValue stores value")
        func initWithRawValue() {
            let flags = Kernel.Event.Poll.Create.Flags(rawValue: 42)
            #expect(flags.rawValue == 42)
        }

        @Test("none has rawValue of 0")
        func noneHasZeroRawValue() {
            #expect(Kernel.Event.Poll.Create.Flags.none.rawValue == 0)
        }

        @Test("cloexec has non-zero rawValue")
        func cloexecHasNonZeroRawValue() {
            #expect(Kernel.Event.Poll.Create.Flags.cloexec.rawValue != 0)
        }

        @Test("flags can be combined with union")
        func flagsCombineWithUnion() {
            let combined = Kernel.Event.Poll.Create.Flags.cloexec.union(.none)
            #expect(combined.rawValue == Kernel.Event.Poll.Create.Flags.cloexec.rawValue)
        }

        @Test("rawValue roundtrip preserves value")
        func rawValueRoundtrip() {
            let original: Int32 = 0x7FFF_FFFF
            let flags = Kernel.Event.Poll.Create.Flags(rawValue: original)
            #expect(flags.rawValue == original)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Event.Poll.Create.Flags.Test.Unit {
        @Test("Create.Flags is Sendable")
        func isSendable() {
            let flags: any Sendable = Kernel.Event.Poll.Create.Flags.cloexec
            #expect(flags is Kernel.Event.Poll.Create.Flags)
        }

        @Test("Create.Flags is Equatable")
        func isEquatable() {
            let a = Kernel.Event.Poll.Create.Flags.cloexec
            let b = Kernel.Event.Poll.Create.Flags.cloexec
            let c = Kernel.Event.Poll.Create.Flags.none
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Create.Flags is Hashable")
        func isHashable() {
            var set = Set<Kernel.Event.Poll.Create.Flags>()
            set.insert(.cloexec)
            set.insert(.none)
            set.insert(.cloexec)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Event.Poll.Create.Flags.Test.EdgeCase {
        @Test("combining same flag is idempotent")
        func combiningIdempotent() {
            let combined: Kernel.Event.Poll.Create.Flags = [.cloexec, .cloexec]
            #expect(combined == .cloexec)
        }

        @Test("combining with none is identity")
        func combiningWithNoneIsIdentity() {
            let combined = Kernel.Event.Poll.Create.Flags.cloexec.union(.none)
            #expect(combined == .cloexec)
        }

        @Test("none combined with none is none")
        func noneCombinedWithNone() {
            let combined = Kernel.Event.Poll.Create.Flags.none.union(.none)
            #expect(combined == .none)
        }
    }
#endif
