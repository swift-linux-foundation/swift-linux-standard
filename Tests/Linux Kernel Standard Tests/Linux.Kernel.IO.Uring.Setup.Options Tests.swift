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

        @Test
        func `flags combine with union`() {
            let combined = Kernel.IO.Uring.Setup.Options.ioPoll.union(.sqPoll)
            #expect(combined.contains(.ioPoll))
            #expect(combined.contains(.sqPoll))
            #expect(!combined.contains(.sqAff))
        }

        @Test
        func `empty flags is empty`() {
            let flags: Kernel.IO.Uring.Setup.Options = []
            #expect(flags.isEmpty)
            #expect(flags.rawValue == 0)
        }

        @Test
        func `ioPoll has rawValue 1`() {
            #expect(Kernel.IO.Uring.Setup.Options.ioPoll.rawValue == 1)
        }

        @Test
        func `sqPoll has rawValue 2`() {
            #expect(Kernel.IO.Uring.Setup.Options.sqPoll.rawValue == 2)
        }

        @Test
        func `flags are distinct`() {
            #expect(Kernel.IO.Uring.Setup.Options.ioPoll != .sqPoll)
            #expect(Kernel.IO.Uring.Setup.Options.sqPoll != .sqAff)
            #expect(Kernel.IO.Uring.Setup.Options.sqAff != .cqSize)
        }
    }

#endif
