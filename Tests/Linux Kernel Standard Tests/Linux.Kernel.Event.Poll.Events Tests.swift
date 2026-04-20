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
    import Kernel_Event_Primitives
    import Kernel_IO_Primitives
    import Kernel_Descriptor_Primitives
    import Kernel_Error_Primitives
    import Kernel_File_Primitives
    import Kernel_Memory_Primitives
    @testable import Linux_Kernel_Event_Standard

    extension Kernel.Event.Poll.Events {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Bridging Unit Tests

    extension Kernel.Event.Poll.Events.Test.Unit {

        @Test
        func `in and out events are distinct`() {
            #expect(Kernel.Event.Poll.Events.in != .out)
            #expect(Kernel.Event.Poll.Events.in.rawValue != Kernel.Event.Poll.Events.out.rawValue)
        }

        @Test
        func `events combine with OR operator`() {
            let combined: Kernel.Event.Poll.Events = [.in, .out]
            #expect(combined.contains(.in))
            #expect(combined.contains(.out))
            #expect(!combined.contains(.err))
        }

        @Test
        func `contains detects single event`() {
            let events: Kernel.Event.Poll.Events = .in
            #expect(events.contains(.in))
            #expect(!events.contains(.out))
        }

        @Test
        func `in event has non-zero rawValue`() {
            #expect(Kernel.Event.Poll.Events.in.rawValue != 0)
        }

        @Test
        func `out event has non-zero rawValue`() {
            #expect(Kernel.Event.Poll.Events.out.rawValue != 0)
        }

        @Test
        func `in and out have different rawValues`() {
            #expect(Kernel.Event.Poll.Events.in.rawValue != Kernel.Event.Poll.Events.out.rawValue)
        }
    }

#endif
