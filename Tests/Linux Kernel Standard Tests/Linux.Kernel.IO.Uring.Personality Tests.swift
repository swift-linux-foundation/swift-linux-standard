#if os(Linux)
    import Testing
    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        import Linux_Kernel_Shims
    #endif

    extension Kernel.IO.Uring.Personality {
        enum Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

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
            #expect(id.underlying == 42)
        }

        @Test
        func `ID.none constant has rawValue 0`() {
            let none = Kernel.IO.Uring.Personality.ID.none
            #expect(none.underlying == 0)
        }

        @Test
        func `ID rawValue access`() {
            let id: Kernel.IO.Uring.Personality.ID = 7
            #expect(id.underlying == 7)
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
            set.insert(.none)
            #expect(set.count == 2)
        }
    }

    extension Kernel.IO.Uring.Personality.Test.`Edge Case` {
        @Test
        func `ID UInt16.max value`() {
            let id = Kernel.IO.Uring.Personality.ID(_unchecked: UInt16.max)
            #expect(id.underlying == UInt16.max)
        }

        @Test
        func `ID rawValue roundtrip`() {
            for value: UInt16 in [0, 1, 100, UInt16.max] {
                let id = Kernel.IO.Uring.Personality.ID(_unchecked: value)
                #expect(id.underlying == value)
            }
        }
    }
#endif
