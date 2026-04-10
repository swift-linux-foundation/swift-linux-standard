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
    @testable import Linux_Kernel_Primitives

    extension Kernel.IO.Uring.Enter.Options {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Enter.Options.Test.Unit {
        @Test("Enter.Options from rawValue")
        func rawValueInit() {
            let flags = Kernel.IO.Uring.Enter.Options(rawValue: 0x07)
            #expect(flags.rawValue == 0x07)
        }

        @Test("getEvents has rawValue 1")
        func getEventsRawValue() {
            #expect(Kernel.IO.Uring.Enter.Options.getEvents.rawValue == 1)
        }

        @Test("sqWakeup has rawValue 2")
        func sqWakeupRawValue() {
            #expect(Kernel.IO.Uring.Enter.Options.sqWakeup.rawValue == 2)
        }

        @Test("sqWait has rawValue 4")
        func sqWaitRawValue() {
            #expect(Kernel.IO.Uring.Enter.Options.sqWait.rawValue == 4)
        }

        @Test("extArg has rawValue 8")
        func extArgRawValue() {
            #expect(Kernel.IO.Uring.Enter.Options.extArg.rawValue == 8)
        }

        @Test("registeredRing has rawValue 16")
        func registeredRingRawValue() {
            #expect(Kernel.IO.Uring.Enter.Options.registeredRing.rawValue == 16)
        }
    }

    // MARK: - OptionSet Tests

    extension Kernel.IO.Uring.Enter.Options.Test.Unit {
        @Test("flags combine with union")
        func flagsCombine() {
            let combined = Kernel.IO.Uring.Enter.Options.getEvents.union(.sqWakeup)
            #expect(combined.contains(.getEvents))
            #expect(combined.contains(.sqWakeup))
            #expect(!combined.contains(.sqWait))
        }

        @Test("empty flags is empty")
        func emptyFlags() {
            let flags: Kernel.IO.Uring.Enter.Options = []
            #expect(flags.isEmpty)
            #expect(flags.rawValue == 0)
        }

        @Test("flags can be created with array literal")
        func arrayLiteral() {
            let flags: Kernel.IO.Uring.Enter.Options = [.getEvents, .sqWakeup]
            #expect(flags.contains(.getEvents))
            #expect(flags.contains(.sqWakeup))
        }

        @Test("flags intersection")
        func intersection() {
            let a: Kernel.IO.Uring.Enter.Options = [.getEvents, .sqWakeup]
            let b: Kernel.IO.Uring.Enter.Options = [.sqWakeup, .sqWait]
            let intersection = a.intersection(b)
            #expect(intersection.contains(.sqWakeup))
            #expect(!intersection.contains(.getEvents))
            #expect(!intersection.contains(.sqWait))
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IO.Uring.Enter.Options.Test.Unit {
        @Test("Enter.Options is Sendable")
        func isSendable() {
            let flags: any Sendable = Kernel.IO.Uring.Enter.Options.getEvents
            #expect(flags is Kernel.IO.Uring.Enter.Options)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Enter.Options.Test.EdgeCase {
        @Test("flags are distinct")
        func flagsDistinct() {
            let flags: [Kernel.IO.Uring.Enter.Options] = [
                .getEvents, .sqWakeup, .sqWait, .extArg, .registeredRing,
            ]

            for i in 0..<flags.count {
                for j in (i + 1)..<flags.count {
                    #expect(flags[i] != flags[j])
                }
            }
        }

        @Test("all flags combined")
        func allFlagsCombined() {
            let all: Kernel.IO.Uring.Enter.Options = [
                .getEvents, .sqWakeup, .sqWait, .extArg, .registeredRing,
            ]
            #expect(all.rawValue == 0x1F)
        }
    }
#endif
