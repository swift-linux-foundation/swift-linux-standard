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

    extension Kernel.IO.Uring.Submission {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Submission.Test.Unit {
        @Test
        func `Submission namespace exists`() {
            _ = Kernel.IO.Uring.Submission.self
        }

        @Test
        func `Submission is an enum`() {
            let _: Kernel.IO.Uring.Submission.Type = Kernel.IO.Uring.Submission.self
        }
    }

    // MARK: - Nested Types

    extension Kernel.IO.Uring.Submission.Test.Unit {
        @Test
        func `Submission.Queue type exists`() {
            let _: Kernel.IO.Uring.Submission.Queue.Type = Kernel.IO.Uring.Submission.Queue.self
        }
    }
#endif
