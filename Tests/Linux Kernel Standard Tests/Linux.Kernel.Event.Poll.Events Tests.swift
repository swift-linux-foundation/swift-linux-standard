#if os(Linux)
    import Testing

    import Error
    import Memory
    @testable import Linux_Kernel_Event_Standard

    import Linux_Standard_Core
    private typealias Kernel = Linux.Kernel

    extension Kernel.Event.Poll.Events {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

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
