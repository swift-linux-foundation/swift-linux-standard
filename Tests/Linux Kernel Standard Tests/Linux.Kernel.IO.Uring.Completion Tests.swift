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

    extension Kernel.IO.Uring.Completion {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Completion.Test.Unit {
        @Test
        func `Completion namespace exists`() {
            _ = Kernel.IO.Uring.Completion.self
        }

        @Test
        func `Completion is an enum`() {
            let _: Kernel.IO.Uring.Completion.Type = Kernel.IO.Uring.Completion.self
        }
    }

    // MARK: - Nested Types

    extension Kernel.IO.Uring.Completion.Test.Unit {
        @Test
        func `Completion.Queue type exists`() {
            let _: Kernel.IO.Uring.Completion.Queue.Type = Kernel.IO.Uring.Completion.Queue.self
        }
    }
#endif
