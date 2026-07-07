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

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.IO.Uring.Opcode {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Uring.Opcode.Test.Unit {
        @Test
        func `Opcode from rawValue`() {
            let opcode = Kernel.IO.Uring.Opcode(rawValue: 22)
            #expect(opcode.rawValue == 22)
        }

        @Test
        func `nop has rawValue 0`() {
            #expect(Kernel.IO.Uring.Opcode.nop.rawValue == 0)
        }

        @Test
        func `read.vectored.standard has rawValue 1`() {
            #expect(Kernel.IO.Uring.Read.vectored.standard.rawValue == 1)
        }

        @Test
        func `write.vectored.standard has rawValue 2`() {
            #expect(Kernel.IO.Uring.Write.vectored.standard.rawValue == 2)
        }

        @Test
        func `read.standard has rawValue 22`() {
            #expect(Kernel.IO.Uring.Read.standard.rawValue == 22)
        }

        @Test
        func `write.standard has rawValue 23`() {
            #expect(Kernel.IO.Uring.Write.standard.rawValue == 23)
        }

        @Test
        func `close has rawValue 19`() {
            #expect(Kernel.IO.Uring.Opcode.close.rawValue == 19)
        }

        @Test
        func `socket.accept has rawValue 13`() {
            #expect(Kernel.IO.Uring.Opcode.socket.accept.rawValue == 13)
        }

        @Test
        func `socket.connect has rawValue 16`() {
            #expect(Kernel.IO.Uring.Opcode.socket.connect.rawValue == 16)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IO.Uring.Opcode.Test.Unit {
        @Test
        func `Opcode is Sendable`() {
            let opcode: any Sendable = Kernel.IO.Uring.Opcode.nop
            #expect(opcode is Kernel.IO.Uring.Opcode)
        }

        @Test
        func `Opcode is Equatable`() {
            let a = Kernel.IO.Uring.Read.standard
            let b = Kernel.IO.Uring.Read.standard
            let c = Kernel.IO.Uring.Write.standard
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Opcode is Hashable`() {
            var set = Set<Kernel.IO.Uring.Opcode>()
            set.insert(.nop)
            set.insert(Kernel.IO.Uring.Read.standard)
            set.insert(Kernel.IO.Uring.Write.standard)
            set.insert(.nop)  // duplicate
            #expect(set.count == 3)
        }

        @Test
        func `Opcode is RawRepresentable`() {
            let opcode = Kernel.IO.Uring.Opcode(rawValue: 22)
            #expect(opcode.rawValue == 22)
        }

        @Test
        func `Opcode is CustomStringConvertible`() {
            let opcode: any CustomStringConvertible = Kernel.IO.Uring.Read.standard
            #expect(opcode.description == "READ")
        }
    }

    // MARK: - Description Tests

    extension Kernel.IO.Uring.Opcode.Test.Unit {
        @Test
        func `nop description`() {
            #expect(Kernel.IO.Uring.Opcode.nop.description == "NOP")
        }

        @Test
        func `read.standard description`() {
            #expect(Kernel.IO.Uring.Read.standard.description == "READ")
        }

        @Test
        func `write.standard description`() {
            #expect(Kernel.IO.Uring.Write.standard.description == "WRITE")
        }

        @Test
        func `unknown opcode description`() {
            let opcode = Kernel.IO.Uring.Opcode(rawValue: 200)
            #expect(opcode.description.contains("OPCODE"))
            #expect(opcode.description.contains("200"))
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Opcode.Test.EdgeCase {
        @Test
        func `opcodes with same rawValue are equal`() {
            let a = Kernel.IO.Uring.Opcode(rawValue: 22)
            let b = Kernel.IO.Uring.Read.standard
            #expect(a == b)
        }

        @Test
        func `opcodes are distinct`() {
            let opcodes: [Kernel.IO.Uring.Opcode] = [
                .nop,
                .close,
                .nop128,
                Kernel.IO.Uring.Read.standard,
                Kernel.IO.Uring.Read.Vectored.standard,
                Kernel.IO.Uring.Read.Vectored.fixed,
                Kernel.IO.Uring.Read.fixed,
                Kernel.IO.Uring.Read.multishot,
                Kernel.IO.Uring.Write.standard,
                Kernel.IO.Uring.Write.Vectored.standard,
                Kernel.IO.Uring.Write.Vectored.fixed,
                Kernel.IO.Uring.Write.fixed,
                Kernel.IO.Uring.Sync.File.standard,
                Kernel.IO.Uring.Sync.File.range,
                Kernel.IO.Uring.Socket.accept,
                Kernel.IO.Uring.Socket.connect,
                Kernel.IO.Uring.Socket.send,
                Kernel.IO.Uring.Socket.receive,
                Kernel.IO.Uring.Socket.Message.send,
                Kernel.IO.Uring.Socket.Message.receive,
                Kernel.IO.Uring.Socket.shutdown,
                Kernel.IO.Uring.Socket.create,
                Kernel.IO.Uring.Socket.bind,
                Kernel.IO.Uring.Socket.listen,
                Kernel.IO.Uring.Socket.receiveZeroCopy,
                Kernel.IO.Uring.Cancel.async,
                Kernel.IO.Uring.Timeout.standard,
                Kernel.IO.Uring.Timeout.remove,
                Kernel.IO.Uring.Timeout.link,
                Kernel.IO.Uring.Poll.add,
                Kernel.IO.Uring.Poll.remove,
                Kernel.IO.Uring.File.openat,
                Kernel.IO.Uring.File.openat2,
                Kernel.IO.Uring.File.statx,
                Kernel.IO.Uring.File.fallocate,
                Kernel.IO.Uring.File.fadvise,
                Kernel.IO.Uring.File.ftruncate,
                Kernel.IO.Uring.File.renameat,
                Kernel.IO.Uring.File.unlinkat,
                Kernel.IO.Uring.File.mkdirat,
                Kernel.IO.Uring.File.symlinkat,
                Kernel.IO.Uring.File.linkat,
                Kernel.IO.Uring.File.update,
                Kernel.IO.Uring.Send.zero.copy,
                Kernel.IO.Uring.Send.zero.msg,
                Kernel.IO.Uring.Pipe.splice,
                Kernel.IO.Uring.Pipe.tee,
                Kernel.IO.Uring.Pipe.create,
                Kernel.IO.Uring.Buffer.provide,
                Kernel.IO.Uring.Buffer.remove,
                Kernel.IO.Uring.Epoll.ctl,
                Kernel.IO.Uring.Epoll.wait,
                Kernel.IO.Uring.Opcode.Ring.msg,
                Kernel.IO.Uring.Opcode.Ring.cmd,
                Kernel.IO.Uring.Opcode.Ring.cmd128,
                Kernel.IO.Uring.Xattr.fset,
                Kernel.IO.Uring.Xattr.set,
                Kernel.IO.Uring.Xattr.fget,
                Kernel.IO.Uring.Xattr.get,
                Kernel.IO.Uring.Memory.madvise,
                Kernel.IO.Uring.Futex.wait,
                Kernel.IO.Uring.Futex.wake,
                Kernel.IO.Uring.Futex.waitv,
                Kernel.IO.Uring.Wait.id,
                Kernel.IO.Uring.Fixed.install,
            ]

            for i in 0..<opcodes.count {
                for j in (i + 1)..<opcodes.count {
                    #expect(opcodes[i] != opcodes[j])
                }
            }
        }

        @Test
        func `rawValue roundtrip`() {
            for rawValue: UInt8 in [0, 1, 22, 23, 55] {
                let opcode = Kernel.IO.Uring.Opcode(rawValue: rawValue)
                #expect(opcode.rawValue == rawValue)
            }
        }
    }
#endif
