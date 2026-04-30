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

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_Event_Standard

    extension Kernel.Event.Poll.Error {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.Event.Poll.Error.Test.Unit {
        @Test
        func `create case stores error code`() {
            let code = Error_Primitives.Error.Code.posix(EINVAL)
            let error = Kernel.Event.Poll.Error.create(code)
            if case .create(let storedCode) = error {
                #expect(storedCode == code)
            } else {
                Issue.record("Expected .create case")
            }
        }

        @Test
        func `ctl case stores error code`() {
            let code = Error_Primitives.Error.Code.posix(EBADF)
            let error = Kernel.Event.Poll.Error.ctl(code)
            if case .ctl(let storedCode) = error {
                #expect(storedCode == code)
            } else {
                Issue.record("Expected .ctl case")
            }
        }

        @Test
        func `wait case stores error code`() {
            let code = Error_Primitives.Error.Code.posix(EFAULT)
            let error = Kernel.Event.Poll.Error.wait(code)
            if case .wait(let storedCode) = error {
                #expect(storedCode == code)
            } else {
                Issue.record("Expected .wait case")
            }
        }

        @Test
        func `interrupted case exists`() {
            let error = Kernel.Event.Poll.Error.interrupted
            if case .interrupted = error {
                // Expected
            } else {
                Issue.record("Expected .interrupted case")
            }
        }
    }

    // MARK: - Description Tests

    extension Kernel.Event.Poll.Error.Test.Unit {
        @Test
        func `create description format`() {
            let code = Error_Primitives.Error.Code.posix(EINVAL)
            let error = Kernel.Event.Poll.Error.create(code)
            #expect(error.description.contains("epoll_create1 failed"))
        }

        @Test
        func `ctl description format`() {
            let code = Error_Primitives.Error.Code.posix(EBADF)
            let error = Kernel.Event.Poll.Error.ctl(code)
            #expect(error.description.contains("epoll_ctl failed"))
        }

        @Test
        func `wait description format`() {
            let code = Error_Primitives.Error.Code.posix(EFAULT)
            let error = Kernel.Event.Poll.Error.wait(code)
            #expect(error.description.contains("epoll_wait failed"))
        }

        @Test
        func `interrupted description`() {
            let error = Kernel.Event.Poll.Error.interrupted
            #expect(error.description == "operation interrupted")
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Event.Poll.Error.Test.Unit {
        @Test
        func `Error conforms to Swift.Error`() {
            let error: any Swift.Error = Kernel.Event.Poll.Error.interrupted
            #expect(error is Kernel.Event.Poll.Error)
        }

        @Test
        func `Error is Sendable`() {
            let error: any Sendable = Kernel.Event.Poll.Error.interrupted
            #expect(error is Kernel.Event.Poll.Error)
        }

        @Test
        func `Error is Equatable`() {
            let code = Error_Primitives.Error.Code.posix(EINVAL)
            let a = Kernel.Event.Poll.Error.create(code)
            let b = Kernel.Event.Poll.Error.create(code)
            let c = Kernel.Event.Poll.Error.ctl(code)
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Error is Hashable`() {
            var set = Set<Kernel.Event.Poll.Error>()
            set.insert(.interrupted)
            set.insert(.create(Error_Primitives.Error.Code.posix(EINVAL)))
            set.insert(.interrupted)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Event.Poll.Error.Test.EdgeCase {
        @Test
        func `different error codes are not equal`() {
            let error1 = Kernel.Event.Poll.Error.create(Error_Primitives.Error.Code.posix(EINVAL))
            let error2 = Kernel.Event.Poll.Error.create(Error_Primitives.Error.Code.posix(ENOMEM))
            #expect(error1 != error2)
        }

        @Test
        func `same code different case not equal`() {
            let code = Error_Primitives.Error.Code.posix(EINVAL)
            let error1 = Kernel.Event.Poll.Error.create(code)
            let error2 = Kernel.Event.Poll.Error.ctl(code)
            #expect(error1 != error2)
        }

        @Test
        func `interrupted equals itself`() {
            #expect(Kernel.Event.Poll.Error.interrupted == .interrupted)
        }
    }
#endif
