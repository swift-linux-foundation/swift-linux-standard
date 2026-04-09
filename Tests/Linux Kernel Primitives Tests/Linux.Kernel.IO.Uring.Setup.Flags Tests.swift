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

    extension Kernel.IO.Uring.Setup.Flags {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Type Unit Tests

    extension Kernel.IO.Uring.Setup.Flags.Test.Unit {

        @Test("flags combine with union")
        func flagsCombineWithUnion() {
            let combined = Kernel.IO.Uring.Setup.Flags.ioPoll.union(.sqPoll)
            #expect(combined.contains(.ioPoll))
            #expect(combined.contains(.sqPoll))
            #expect(!combined.contains(.sqAff))
        }

        @Test("empty flags is empty")
        func emptyFlagsIsEmpty() {
            let flags: Kernel.IO.Uring.Setup.Flags = []
            #expect(flags.isEmpty)
            #expect(flags.rawValue == 0)
        }

        @Test("ioPoll has rawValue 1")
        func ioPollHasRawValue1() {
            #expect(Kernel.IO.Uring.Setup.Flags.ioPoll.rawValue == 1)
        }

        @Test("sqPoll has rawValue 2")
        func sqPollHasRawValue2() {
            #expect(Kernel.IO.Uring.Setup.Flags.sqPoll.rawValue == 2)
        }

        @Test("flags are distinct")
        func flagsAreDistinct() {
            #expect(Kernel.IO.Uring.Setup.Flags.ioPoll != .sqPoll)
            #expect(Kernel.IO.Uring.Setup.Flags.sqPoll != .sqAff)
            #expect(Kernel.IO.Uring.Setup.Flags.sqAff != .cqSize)
        }
    }

#endif
