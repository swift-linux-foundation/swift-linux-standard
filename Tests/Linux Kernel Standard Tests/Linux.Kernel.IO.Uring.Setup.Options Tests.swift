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
    @testable import Linux_Kernel_IO_Uring_Standard

    extension Kernel.IO.Uring.Setup.Options {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Type Unit Tests

    extension Kernel.IO.Uring.Setup.Options.Test.Unit {

        @Test("flags combine with union")
        func flagsCombineWithUnion() {
            let combined = Kernel.IO.Uring.Setup.Options.ioPoll.union(.sqPoll)
            #expect(combined.contains(.ioPoll))
            #expect(combined.contains(.sqPoll))
            #expect(!combined.contains(.sqAff))
        }

        @Test("empty flags is empty")
        func emptyFlagsIsEmpty() {
            let flags: Kernel.IO.Uring.Setup.Options = []
            #expect(flags.isEmpty)
            #expect(flags.rawValue == 0)
        }

        @Test("ioPoll has rawValue 1")
        func ioPollHasRawValue1() {
            #expect(Kernel.IO.Uring.Setup.Options.ioPoll.rawValue == 1)
        }

        @Test("sqPoll has rawValue 2")
        func sqPollHasRawValue2() {
            #expect(Kernel.IO.Uring.Setup.Options.sqPoll.rawValue == 2)
        }

        @Test("flags are distinct")
        func flagsAreDistinct() {
            #expect(Kernel.IO.Uring.Setup.Options.ioPoll != .sqPoll)
            #expect(Kernel.IO.Uring.Setup.Options.sqPoll != .sqAff)
            #expect(Kernel.IO.Uring.Setup.Options.sqAff != .cqSize)
        }
    }

#endif
