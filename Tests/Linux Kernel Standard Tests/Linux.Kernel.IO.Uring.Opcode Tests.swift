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
    @testable import Linux_Kernel_IO_Uring_Standard

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
        @Test("Opcode from rawValue")
        func rawValueInit() {
            let opcode = Kernel.IO.Uring.Opcode(rawValue: 22)
            #expect(opcode.rawValue == 22)
        }

        @Test("nop has rawValue 0")
        func nopRawValue() {
            #expect(Kernel.IO.Uring.Opcode.nop.rawValue == 0)
        }

        @Test("read.vectored has rawValue 1")
        func readVectoredRawValue() {
            #expect(Kernel.IO.Uring.Read.vectored.rawValue == 1)
        }

        @Test("write.vectored has rawValue 2")
        func writeVectoredRawValue() {
            #expect(Kernel.IO.Uring.Write.vectored.rawValue == 2)
        }

        @Test("read.standard has rawValue 22")
        func readStandardRawValue() {
            #expect(Kernel.IO.Uring.Read.standard.rawValue == 22)
        }

        @Test("write.standard has rawValue 23")
        func writeStandardRawValue() {
            #expect(Kernel.IO.Uring.Write.standard.rawValue == 23)
        }

        @Test("close has rawValue 19")
        func closeRawValue() {
            #expect(Kernel.IO.Uring.Opcode.close.rawValue == 19)
        }

        @Test("socket.accept has rawValue 13")
        func socketAcceptRawValue() {
            #expect(Kernel.IO.Uring.Opcode.socket.accept.rawValue == 13)
        }

        @Test("socket.connect has rawValue 16")
        func socketConnectRawValue() {
            #expect(Kernel.IO.Uring.Opcode.socket.connect.rawValue == 16)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IO.Uring.Opcode.Test.Unit {
        @Test("Opcode is Sendable")
        func isSendable() {
            let opcode: any Sendable = Kernel.IO.Uring.Opcode.nop
            #expect(opcode is Kernel.IO.Uring.Opcode)
        }

        @Test("Opcode is Equatable")
        func isEquatable() {
            let a = Kernel.IO.Uring.Read.standard
            let b = Kernel.IO.Uring.Read.standard
            let c = Kernel.IO.Uring.Write.standard
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Opcode is Hashable")
        func isHashable() {
            var set = Set<Kernel.IO.Uring.Opcode>()
            set.insert(.nop)
            set.insert(Kernel.IO.Uring.Read.standard)
            set.insert(Kernel.IO.Uring.Write.standard)
            set.insert(.nop)  // duplicate
            #expect(set.count == 3)
        }

        @Test("Opcode is RawRepresentable")
        func isRawRepresentable() {
            let opcode = Kernel.IO.Uring.Opcode(rawValue: 22)
            #expect(opcode.rawValue == 22)
        }

        @Test("Opcode is CustomStringConvertible")
        func isCustomStringConvertible() {
            let opcode: any CustomStringConvertible = Kernel.IO.Uring.Read.standard
            #expect(opcode.description == "READ")
        }
    }

    // MARK: - Description Tests

    extension Kernel.IO.Uring.Opcode.Test.Unit {
        @Test("nop description")
        func nopDescription() {
            #expect(Kernel.IO.Uring.Opcode.nop.description == "NOP")
        }

        @Test("read.standard description")
        func readDescription() {
            #expect(Kernel.IO.Uring.Read.standard.description == "READ")
        }

        @Test("write.standard description")
        func writeDescription() {
            #expect(Kernel.IO.Uring.Write.standard.description == "WRITE")
        }

        @Test("unknown opcode description")
        func unknownDescription() {
            let opcode = Kernel.IO.Uring.Opcode(rawValue: 200)
            #expect(opcode.description.contains("OPCODE"))
            #expect(opcode.description.contains("200"))
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Opcode.Test.EdgeCase {
        @Test("opcodes with same rawValue are equal")
        func sameRawValueEqual() {
            let a = Kernel.IO.Uring.Opcode(rawValue: 22)
            let b = Kernel.IO.Uring.Read.standard
            #expect(a == b)
        }

        @Test("opcodes are distinct")
        func opcodesDistinct() {
            let opcodes: [Kernel.IO.Uring.Opcode] = [
                .nop,
                .close,
                .nop128,
                Kernel.IO.Uring.Read.standard,
                Kernel.IO.Uring.Read.vectored,
                Kernel.IO.Uring.Read.fixed,
                Kernel.IO.Uring.Read.multishot,
                Kernel.IO.Uring.Read.vectoredFixed,
                Kernel.IO.Uring.Write.standard,
                Kernel.IO.Uring.Write.vectored,
                Kernel.IO.Uring.Write.fixed,
                Kernel.IO.Uring.Write.vectoredFixed,
                Kernel.IO.Uring.Sync.file,
                Kernel.IO.Uring.Sync.fileRange,
                Kernel.IO.Uring.Socket.accept,
                Kernel.IO.Uring.Socket.connect,
                Kernel.IO.Uring.Socket.send,
                Kernel.IO.Uring.Socket.receive,
                Kernel.IO.Uring.Socket.sendMessage,
                Kernel.IO.Uring.Socket.receiveMessage,
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
                Kernel.IO.Uring.File.filesUpdate,
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
                Kernel.IO.Uring.Fixed.fdInstall,
            ]

            for i in 0..<opcodes.count {
                for j in (i + 1)..<opcodes.count {
                    #expect(opcodes[i] != opcodes[j])
                }
            }
        }

        @Test("rawValue roundtrip")
        func rawValueRoundtrip() {
            for rawValue: UInt8 in [0, 1, 22, 23, 55] {
                let opcode = Kernel.IO.Uring.Opcode(rawValue: rawValue)
                #expect(opcode.rawValue == rawValue)
            }
        }
    }
#endif
