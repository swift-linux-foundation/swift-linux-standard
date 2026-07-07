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
        @Test
        func `Enter.Options from rawValue`() {
            let flags = Kernel.IO.Uring.Enter.Options(rawValue: 0x07)
            #expect(flags.rawValue == 0x07)
        }

        @Test
        func `getEvents has rawValue 1`() {
            #expect(Kernel.IO.Uring.Enter.Options.getEvents.rawValue == 1)
        }

        @Test
        func `sqWakeup has rawValue 2`() {
            #expect(Kernel.IO.Uring.Enter.Options.sqWakeup.rawValue == 2)
        }

        @Test
        func `sqWait has rawValue 4`() {
            #expect(Kernel.IO.Uring.Enter.Options.sqWait.rawValue == 4)
        }

        @Test
        func `extArg has rawValue 8`() {
            #expect(Kernel.IO.Uring.Enter.Options.extArg.rawValue == 8)
        }

        @Test
        func `registeredRing has rawValue 16`() {
            #expect(Kernel.IO.Uring.Enter.Options.registeredRing.rawValue == 16)
        }
    }

    // MARK: - OptionSet Tests

    extension Kernel.IO.Uring.Enter.Options.Test.Unit {
        @Test
        func `flags combine with union`() {
            let combined = Kernel.IO.Uring.Enter.Options.getEvents.union(.sqWakeup)
            #expect(combined.contains(.getEvents))
            #expect(combined.contains(.sqWakeup))
            #expect(!combined.contains(.sqWait))
        }

        @Test
        func `empty flags is empty`() {
            let flags: Kernel.IO.Uring.Enter.Options = []
            #expect(flags.isEmpty)
            #expect(flags.rawValue == 0)
        }

        @Test
        func `flags can be created with array literal`() {
            let flags: Kernel.IO.Uring.Enter.Options = [.getEvents, .sqWakeup]
            #expect(flags.contains(.getEvents))
            #expect(flags.contains(.sqWakeup))
        }

        @Test
        func `flags intersection`() {
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
        @Test
        func `Enter.Options is Sendable`() {
            let flags: any Sendable = Kernel.IO.Uring.Enter.Options.getEvents
            #expect(flags is Kernel.IO.Uring.Enter.Options)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Enter.Options.Test.EdgeCase {
        @Test
        func `flags are distinct`() {
            let flags: [Kernel.IO.Uring.Enter.Options] = [
                .getEvents, .sqWakeup, .sqWait, .extArg, .registeredRing,
            ]

            for i in 0..<flags.count {
                for j in (i + 1)..<flags.count {
                    #expect(flags[i] != flags[j])
                }
            }
        }

        @Test
        func `all flags combined`() {
            let all: Kernel.IO.Uring.Enter.Options = [
                .getEvents, .sqWakeup, .sqWait, .extArg, .registeredRing,
            ]
            #expect(all.rawValue == 0x1F)
        }
    }
#endif
