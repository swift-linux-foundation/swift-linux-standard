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

    extension Kernel.IO.Uring.Operation {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Operation.Test.Unit {
        @Test("Operation namespace exists")
        func namespaceExists() {
            _ = Kernel.IO.Uring.Operation.self
        }

        @Test("Operation is an enum")
        func isEnum() {
            let _: Kernel.IO.Uring.Operation.Type = Kernel.IO.Uring.Operation.self
        }
    }

    // MARK: - Nested Types

    extension Kernel.IO.Uring.Operation.Test.Unit {
        @Test("Operation.Data type exists")
        func dataTypeExists() {
            let _: Kernel.IO.Uring.Operation.Data.Type = Kernel.IO.Uring.Operation.Data.self
        }
    }
#endif
