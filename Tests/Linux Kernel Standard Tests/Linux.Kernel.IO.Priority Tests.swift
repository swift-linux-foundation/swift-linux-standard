#if os(Linux)
    import Testing

    import Error
    import Memory
    @testable import Linux_Kernel_IO_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Priority {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Priority.Test.Unit {
        @Test
        func `Priority from rawValue`() {
            let priority = Kernel.IO.Priority(rawValue: 100)
            #expect(priority.rawValue == 100)
        }

        @Test
        func `Priority from UInt16`() {
            let priority = Kernel.IO.Priority(50)
            #expect(priority.rawValue == 50)
        }

        @Test
        func `Priority.default constant`() {
            #expect(Kernel.IO.Priority.default.rawValue == 0)
        }

        @Test
        func `Priority.normal constant`() {
            #expect(Kernel.IO.Priority.normal.rawValue == 0)
        }

        @Test
        func `Priority integer literal`() {
            let priority: Kernel.IO.Priority = 42
            #expect(priority.rawValue == 42)
        }

        @Test
        func `Priority description`() {
            let priority = Kernel.IO.Priority(123)
            #expect(priority.description == "123")
        }
    }

    extension Kernel.IO.Priority.Test.Unit {
        @Test
        func `Priority is Sendable`() {
            let priority: any Sendable = Kernel.IO.Priority(0)
            #expect(priority is Kernel.IO.Priority)
        }

        @Test
        func `Priority is Equatable`() {
            let a = Kernel.IO.Priority(10)
            let b = Kernel.IO.Priority(10)
            let c = Kernel.IO.Priority(20)
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Priority is Hashable`() {
            var set = Set<Kernel.IO.Priority>()
            set.insert(.default)
            set.insert(Kernel.IO.Priority(100))
            set.insert(.default)
            #expect(set.count == 2)
        }

        @Test
        func `Priority is Comparable`() {
            let low = Kernel.IO.Priority(10)
            let high = Kernel.IO.Priority(100)
            #expect(low < high)
            #expect(high > low)
        }

        @Test
        func `Priority is RawRepresentable`() {
            let priority = Kernel.IO.Priority(rawValue: 50)
            #expect(priority.rawValue == 50)
        }
    }

    extension Kernel.IO.Priority.Test.EdgeCase {
        @Test
        func `Priority max value`() {
            let priority = Kernel.IO.Priority(UInt16.max)
            #expect(priority.rawValue == UInt16.max)
        }

        @Test
        func `default and normal are equal`() {
            #expect(Kernel.IO.Priority.default == Kernel.IO.Priority.normal)
        }

        @Test
        func `Priority ordering`() {
            let priorities = [
                Kernel.IO.Priority(100),
                Kernel.IO.Priority(50),
                Kernel.IO.Priority(200),
            ]
            let sorted = priorities.sorted()
            #expect(sorted[0].rawValue == 50)
            #expect(sorted[1].rawValue == 100)
            #expect(sorted[2].rawValue == 200)
        }
    }
#endif
