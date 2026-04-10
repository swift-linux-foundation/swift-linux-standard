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
    @testable import Linux_Kernel_Standard

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
        @Test("Submission namespace exists")
        func namespaceExists() {
            _ = Kernel.IO.Uring.Submission.self
        }

        @Test("Submission is an enum")
        func isEnum() {
            let _: Kernel.IO.Uring.Submission.Type = Kernel.IO.Uring.Submission.self
        }
    }

    // MARK: - Nested Types

    extension Kernel.IO.Uring.Submission.Test.Unit {
        @Test("Submission.Queue type exists")
        func queueTypeExists() {
            let _: Kernel.IO.Uring.Submission.Queue.Type = Kernel.IO.Uring.Submission.Queue.self
        }
    }
#endif
