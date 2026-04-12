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
    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif
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

    extension Kernel.IO.Uring {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Syscall Unit Tests

    extension Kernel.IO.Uring.Test.Unit {

        @Test("setup with invalid entries throws")
        func setupWithInvalidEntriesThrows() throws {
            var params = Kernel.IO.Uring.Params()

            // 0 entries should fail
            #expect(throws: Kernel.IO.Uring.Error.self) {
                _ = try Kernel.IO.Uring.setup(
                    entries: Kernel.IO.Uring.Submission.Count(__unchecked: (), Cardinal(0)),
                    params: &params
                )
            }
        }
    }

#endif
