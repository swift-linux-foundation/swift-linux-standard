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
    import Kernel_IO_Primitives
    import Error_Primitives
    import Kernel_File_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.Params {
        enum Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Params.Test.Unit {
        @Test
        func `Params default init produces zeroed state`() {
            let params = Kernel.IO.Uring.Params()
            #expect(params.sqEntries.rawValue == Cardinal(0))
            #expect(params.cqEntries.rawValue == Cardinal(0))
            #expect(params.flags.isEmpty)
        }

        @Test
        func `Params init with flags`() {
            let params = Kernel.IO.Uring.Params(flags: .sqPoll)
            #expect(params.flags == .sqPoll)
        }

        @Test
        func `Params is Sendable`() {
            let params: any Sendable = Kernel.IO.Uring.Params()
            #expect(params is Kernel.IO.Uring.Params)
        }

        @Test
        func `Params is Equatable`() {
            let a = Kernel.IO.Uring.Params()
            let b = Kernel.IO.Uring.Params()
            let c = Kernel.IO.Uring.Params(flags: .sqPoll)
            #expect(a == b)
            #expect(a != c)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Params.Test.`Edge Case` {
        @Test
        func `Params with multiple flags`() {
            let flags: Kernel.IO.Uring.Setup.Options = [.ioPoll, .sqPoll, .sqAff]
            let params = Kernel.IO.Uring.Params(flags: flags)
            #expect(params.flags.contains(.ioPoll))
            #expect(params.flags.contains(.sqPoll))
            #expect(params.flags.contains(.sqAff))
        }
    }
#endif
