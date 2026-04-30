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

    #if canImport(CLinuxKernelShim)
        import CLinuxKernelShim
    #endif
import Testing

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_Event_Standard

    extension Kernel.Event.Poll.Operation {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Bridging Unit Tests

    extension Kernel.Event.Poll.Operation.Test.Unit {

        @Test
        func `add operation rawValue matches EPOLL_CTL_ADD`() {
            #expect(Kernel.Event.Poll.Operation.add.rawValue == EPOLL_CTL_ADD)
        }

        @Test
        func `modify operation rawValue matches EPOLL_CTL_MOD`() {
            #expect(Kernel.Event.Poll.Operation.modify.rawValue == EPOLL_CTL_MOD)
        }

        @Test
        func `delete operation rawValue matches EPOLL_CTL_DEL`() {
            #expect(Kernel.Event.Poll.Operation.delete.rawValue == EPOLL_CTL_DEL)
        }

        @Test
        func `operations are distinct`() {
            #expect(Kernel.Event.Poll.Operation.add != .modify)
            #expect(Kernel.Event.Poll.Operation.add != .delete)
            #expect(Kernel.Event.Poll.Operation.modify != .delete)
        }

        @Test
        func `operation conforms to Equatable`() {
            let op1 = Kernel.Event.Poll.Operation.add
            let op2 = Kernel.Event.Poll.Operation.add
            let op3 = Kernel.Event.Poll.Operation.delete

            #expect(op1 == op2)
            #expect(op1 != op3)
        }
    }

#endif
