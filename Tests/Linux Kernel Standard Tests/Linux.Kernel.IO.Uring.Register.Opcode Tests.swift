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

    import Kernel_IO_Primitives
    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    extension Kernel.IO.Uring.Register.Opcode {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Register.Opcode.Test.Unit {
        @Test
        func `Register.Opcode type exists`() {
            let _: Kernel.IO.Uring.Register.Opcode.Type = Kernel.IO.Uring.Register.Opcode.self
        }

        @Test
        func `Register.Opcode from rawValue`() {
            let opcode = Kernel.IO.Uring.Register.Opcode(rawValue: 42)
            #expect(opcode.rawValue == 42)
        }

        @Test
        func `buffers.register constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.buffers.register.rawValue == 0)
        }

        @Test
        func `buffers.unregister constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.buffers.unregister.rawValue == 1)
        }

        @Test
        func `files.register constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.files.register.rawValue == 2)
        }

        @Test
        func `files.unregister constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.files.unregister.rawValue == 3)
        }

        @Test
        func `eventfd.register constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.eventfd.register.rawValue == 4)
        }

        @Test
        func `eventfd.unregister constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.eventfd.unregister.rawValue == 5)
        }

        @Test
        func `files.update constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.files.update.rawValue == 6)
        }

        @Test
        func `eventfd.async constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.eventfd.async.rawValue == 7)
        }

        @Test
        func `probe.register constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.probe.register.rawValue == 8)
        }

        @Test
        func `personality.register constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.personality.register.rawValue == 9)
        }

        @Test
        func `personality.unregister constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.personality.unregister.rawValue == 10)
        }

        @Test
        func `rings.enable constant`() {
            #expect(Kernel.IO.Uring.Register.Opcode.rings.enable.rawValue == 12)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IO.Uring.Register.Opcode.Test.Unit {
        @Test
        func `Register.Opcode is Sendable`() {
            let opcode: any Sendable = Kernel.IO.Uring.Register.Opcode.buffers.register
            #expect(opcode is Kernel.IO.Uring.Register.Opcode)
        }

        @Test
        func `Register.Opcode is Equatable`() {
            let a = Kernel.IO.Uring.Register.Opcode.files.register
            let b = Kernel.IO.Uring.Register.Opcode.files.register
            let c = Kernel.IO.Uring.Register.Opcode.files.unregister
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Register.Opcode is Hashable`() {
            var set = Set<Kernel.IO.Uring.Register.Opcode>()
            set.insert(.buffers.register)
            set.insert(.files.register)
            set.insert(.buffers.register)  // duplicate
            #expect(set.count == 2)
        }

        @Test
        func `Register.Opcode is RawRepresentable`() {
            let opcode = Kernel.IO.Uring.Register.Opcode(rawValue: 4)
            #expect(opcode == .eventfd.register)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Register.Opcode.Test.EdgeCase {
        @Test
        func `all opcodes have unique rawValues`() {
            let opcodes: [Kernel.IO.Uring.Register.Opcode] = [
                .buffers.register,
                .buffers.unregister,
                .files.register,
                .files.unregister,
                .eventfd.register,
                .eventfd.unregister,
                .files.update,
                .eventfd.async,
                .probe.register,
                .personality.register,
                .personality.unregister,
                .rings.enable,
            ]
            let rawValues = opcodes.map(\.rawValue)
            let uniqueValues = Set(rawValues)
            #expect(rawValues.count == uniqueValues.count)
        }

        @Test
        func `rawValue roundtrip`() {
            for rawValue: UInt32 in [0, 1, 5, 11] {
                let opcode = Kernel.IO.Uring.Register.Opcode(rawValue: rawValue)
                #expect(opcode.rawValue == rawValue)
            }
        }
    }
#endif
