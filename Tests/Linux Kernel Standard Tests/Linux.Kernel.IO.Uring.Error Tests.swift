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
    import Kernel_IO_Primitives
    import Error_Primitives
    import Kernel_File_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    extension Kernel.IO.Uring.Error {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Error.Test.Unit {
        @Test
        func `setup case exists`() {
            let code = Error_Primitives.Error.Code.posix(1)
            let error = Kernel.IO.Uring.Error.setup(code)
            if case .setup(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .setup case")
            }
        }

        @Test
        func `enter case exists`() {
            let code = Error_Primitives.Error.Code.posix(2)
            let error = Kernel.IO.Uring.Error.enter(code)
            if case .enter(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .enter case")
            }
        }

        @Test
        func `register case exists`() {
            let code = Error_Primitives.Error.Code.posix(3)
            let error = Kernel.IO.Uring.Error.register(code)
            if case .register(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .register case")
            }
        }

        @Test
        func `interrupted case exists`() {
            let error = Kernel.IO.Uring.Error.interrupted
            if case .interrupted = error {
                // Expected
            } else {
                Issue.record("Expected .interrupted case")
            }
        }
    }

    // MARK: - Description Tests

    extension Kernel.IO.Uring.Error.Test.Unit {
        @Test
        func `setup description format`() {
            let error = Kernel.IO.Uring.Error.setup(.posix(1))
            #expect(error.description.contains("io_uring_setup"))
        }

        @Test
        func `enter description format`() {
            let error = Kernel.IO.Uring.Error.enter(.posix(1))
            #expect(error.description.contains("io_uring_enter"))
        }

        @Test
        func `register description format`() {
            let error = Kernel.IO.Uring.Error.register(.posix(1))
            #expect(error.description.contains("io_uring_register"))
        }

        @Test
        func `interrupted description format`() {
            let error = Kernel.IO.Uring.Error.interrupted
            #expect(error.description.contains("interrupted"))
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IO.Uring.Error.Test.Unit {
        @Test
        func `Error conforms to Swift.Error`() {
            let error: any Swift.Error = Kernel.IO.Uring.Error.interrupted
            #expect(error is Kernel.IO.Uring.Error)
        }

        @Test
        func `Error is Sendable`() {
            let error: any Sendable = Kernel.IO.Uring.Error.interrupted
            #expect(error is Kernel.IO.Uring.Error)
        }

        @Test
        func `Error is Equatable`() {
            let a = Kernel.IO.Uring.Error.interrupted
            let b = Kernel.IO.Uring.Error.interrupted
            let c = Kernel.IO.Uring.Error.setup(.posix(1))
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Error is Hashable`() {
            var set = Set<Kernel.IO.Uring.Error>()
            set.insert(.setup(.posix(1)))
            set.insert(.enter(.posix(2)))
            set.insert(.register(.posix(3)))
            set.insert(.interrupted)
            set.insert(.setup(.posix(1)))  // duplicate
            #expect(set.count == 4)
        }

        @Test
        func `Error is CustomStringConvertible`() {
            let error: any CustomStringConvertible = Kernel.IO.Uring.Error.interrupted
            #expect(!error.description.isEmpty)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Error.Test.EdgeCase {
        @Test
        func `all cases are distinct`() {
            let code = Error_Primitives.Error.Code.posix(1)
            let cases: [Kernel.IO.Uring.Error] = [
                .setup(code),
                .enter(code),
                .register(code),
                .interrupted,
            ]

            for i in 0..<cases.count {
                for j in (i + 1)..<cases.count {
                    #expect(cases[i] != cases[j])
                }
            }
        }

        @Test
        func `same case with different codes are distinct`() {
            let a = Kernel.IO.Uring.Error.setup(.posix(1))
            let b = Kernel.IO.Uring.Error.setup(.posix(2))
            #expect(a != b)
        }

        @Test
        func `all descriptions are non-empty`() {
            let code = Error_Primitives.Error.Code.posix(1)
            let cases: [Kernel.IO.Uring.Error] = [
                .setup(code),
                .enter(code),
                .register(code),
                .interrupted,
            ]

            for error in cases {
                #expect(!error.description.isEmpty)
            }
        }
    }
#endif
