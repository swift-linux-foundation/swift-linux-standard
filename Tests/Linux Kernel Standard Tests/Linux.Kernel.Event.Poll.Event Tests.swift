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
    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

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

    extension Kernel.Event.Poll.Event {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.Event.Poll.Event.Test.Unit {
        @Test("init with events and default data")
        func initWithEventsDefaultData() {
            let event = Kernel.Event.Poll.Event(events: .in)
            #expect(event.events == .in)
            #expect(event.data == .zero)
        }

        @Test("init with events and explicit data")
        func initWithEventsAndData() {
            let data = Kernel.Event.Poll.Data(42)
            let event = Kernel.Event.Poll.Event(events: .out, data: data)
            #expect(event.events == .out)
            #expect(event.data == 42)
        }

        @Test("events property is mutable")
        func eventsIsMutable() {
            var event = Kernel.Event.Poll.Event(events: .in)
            event.events = .out
            #expect(event.events == .out)
        }

        @Test("data property is mutable")
        func dataIsMutable() {
            var event = Kernel.Event.Poll.Event(events: .in)
            event.data = Kernel.Event.Poll.Data(100)
            #expect(event.data == 100)
        }

        @Test("combined events are preserved")
        func combinedEvents() {
            let events: Kernel.Event.Poll.Events = [.in, .out]
            let event = Kernel.Event.Poll.Event(events: events)
            #expect(events.contains(.in))
            #expect(events.contains(.out))
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Event.Poll.Event.Test.Unit {
        @Test("Event is Sendable")
        func isSendable() {
            let event: any Sendable = Kernel.Event.Poll.Event(events: .in)
            #expect(event is Kernel.Event.Poll.Event)
        }

        @Test("Event is Equatable")
        func isEquatable() {
            let a = Kernel.Event.Poll.Event(events: .in, data: Kernel.Event.Poll.Data(1))
            let b = Kernel.Event.Poll.Event(events: .in, data: Kernel.Event.Poll.Data(1))
            let c = Kernel.Event.Poll.Event(events: .out, data: Kernel.Event.Poll.Data(1))
            let d = Kernel.Event.Poll.Event(events: .in, data: Kernel.Event.Poll.Data(2))
            #expect(a == b)
            #expect(a != c)
            #expect(a != d)
        }

        @Test("Event is Hashable")
        func isHashable() {
            var set = Set<Kernel.Event.Poll.Event>()
            set.insert(Kernel.Event.Poll.Event(events: .in, data: Kernel.Event.Poll.Data(1)))
            set.insert(Kernel.Event.Poll.Event(events: .out, data: Kernel.Event.Poll.Data(2)))
            set.insert(Kernel.Event.Poll.Event(events: .in, data: Kernel.Event.Poll.Data(1)))  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Event.Poll.Event.Test.EdgeCase {
        @Test("event with all flags combined")
        func allFlagsCombined() {
            let events: Kernel.Event.Poll.Events = [.in, .out, .err, .hup]
            let event = Kernel.Event.Poll.Event(events: events)
            #expect(events.contains(.in))
            #expect(events.contains(.out))
            #expect(events.contains(.err))
            #expect(events.contains(.hup))
        }

        @Test("event with max data value")
        func maxDataValue() {
            let event = Kernel.Event.Poll.Event(events: .in, data: Kernel.Event.Poll.Data(UInt64.max))
            #expect(event.data.rawValue == UInt64.max)
        }

        @Test("event with zero data")
        func zeroData() {
            let event = Kernel.Event.Poll.Event(events: .in, data: .zero)
            #expect(event.data == 0)
        }
    }
#endif
