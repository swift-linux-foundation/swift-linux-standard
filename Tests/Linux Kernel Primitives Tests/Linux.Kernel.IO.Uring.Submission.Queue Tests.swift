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
        @Test("Queue namespace exists")
        func namespaceExists() {
            _ = Kernel.IO.Uring.Submission.Queue.self
        }

        @Test("Queue is an enum")
        func isEnum() {
            let _: Kernel.IO.Uring.Submission.Queue.Type = Kernel.IO.Uring.Submission.Queue.self
        }
    }

    // MARK: - Nested Types

    extension Kernel.IO.Uring.Submission.Queue.Test.Unit {
        @Test("Queue.Entry type exists")
        func entryTypeExists() {
            let _: Kernel.IO.Uring.Submission.Queue.Entry.Type = Kernel.IO.Uring.Submission.Queue.Entry.self
        }

        @Test("Queue.Offsets type exists")
        func offsetsTypeExists() {
            let _: Kernel.IO.Uring.Submission.Queue.Offsets.Type = Kernel.IO.Uring.Submission.Queue.Offsets.self
        }
    }
#endif
