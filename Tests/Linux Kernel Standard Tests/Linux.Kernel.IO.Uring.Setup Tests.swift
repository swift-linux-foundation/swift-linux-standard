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

    extension Kernel.IO.Uring.Setup {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Setup.Test.Unit {
        @Test
        func `Setup namespace exists`() {
            _ = Kernel.IO.Uring.Setup.self
        }

        @Test
        func `Setup is an enum`() {
            let _: Kernel.IO.Uring.Setup.Type = Kernel.IO.Uring.Setup.self
        }
    }

    // MARK: - Nested Types

    extension Kernel.IO.Uring.Setup.Test.Unit {
        @Test
        func `Setup.Options type exists`() {
            let _: Kernel.IO.Uring.Setup.Options.Type = Kernel.IO.Uring.Setup.Options.self
        }
    }
#endif
