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
    import Error_Primitives
    import Kernel_File_Primitives
    import Kernel_Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    extension Kernel.IO.Uring.Submission.Queue {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Submission.Queue.Test.Unit {
        @Test
        func `Queue namespace exists`() {
            _ = Kernel.IO.Uring.Submission.Queue.self
        }

        @Test
        func `Queue is an enum`() {
            let _: Kernel.IO.Uring.Submission.Queue.Type = Kernel.IO.Uring.Submission.Queue.self
        }
    }

    // MARK: - Nested Types

    extension Kernel.IO.Uring.Submission.Queue.Test.Unit {
        @Test
        func `Queue.Entry type exists`() {
            let _: Kernel.IO.Uring.Submission.Queue.Entry.Type = Kernel.IO.Uring.Submission.Queue.Entry.self
        }

        @Test
        func `Queue.Offsets type exists`() {
            let _: Kernel.IO.Uring.Submission.Queue.Offsets.Type = Kernel.IO.Uring.Submission.Queue.Offsets.self
        }
    }
#endif
