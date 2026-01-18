// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)
    import Test_Primitives
import Testing

    import Kernel_Primitives
    @testable import Linux_Kernel_Primitives

    extension Kernel.IO.Uring.Completion.Queue.Entry.Flags {
        #Tests
    }
#endif
