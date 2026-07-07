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
    import Testing

    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard
    import Linux_Kernel_Socket_Standard
    import Linux_Kernel_Pipe_Standard
    import Linux_Kernel_File_Standard
    import Linux_Kernel_Event_Standard
    import Linux_Kernel_Futex_Standard
    import Linux_Kernel_Memory_Standard
    import ISO_9945_Kernel_File

    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.Submission.Queue.Entry {
        enum PrepareTest {
            @Suite struct Unit {}
        }
    }

    // MARK: - Basic Operations

    extension Kernel.IO.Uring.Submission.Queue.Entry.PrepareTest.Unit {
        @Test
        func `nop sets opcode and data`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 42
            entry.nop(data: data)
            #expect(entry.opcode == .nop)
            #expect(entry.data == data)
        }

        @Test
        func `read sets opcode, target, buffer addr, length, and offset`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 99
            let buf = unsafe UnsafeMutableRawPointer(bitPattern: 0x1000)!
            unsafe entry.read(
                target: .registered(7),
                buffer: buf,
                length: 4096,
                offset: 200,
                data: data
            )
            #expect(entry.opcode == .read.standard)
            #expect(entry.cValue.fd == 7)
            #expect(entry.flags.contains(.fixedFile))
            #expect(entry.addr == 0x1000)
            #expect(entry.len == 4096)
            #expect(entry.offset == 200)
            #expect(entry.data == data)
        }

        @Test
        func `write sets opcode, target, buffer addr, length, and offset`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 100
            let buf = unsafe UnsafeRawPointer(bitPattern: 0x2000)!
            unsafe entry.write(
                target: .registered(8),
                buffer: buf,
                length: 2048,
                offset: .zero,
                data: data
            )
            #expect(entry.opcode == .write.standard)
            #expect(entry.cValue.fd == 8)
            #expect(entry.addr == 0x2000)
            #expect(entry.len == 2048)
            #expect(entry.data == data)
        }

        @Test
        func `cancel sets opcode and target data`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let cancelTarget: Kernel.IO.Uring.Operation.Data = 0xBEEF
            let data: Kernel.IO.Uring.Operation.Data = 0xCAFE
            entry.cancel(target: cancelTarget, data: data)
            #expect(entry.opcode == .cancel.async)
            #expect(entry.addr == 0xBEEF)
            #expect(entry.data == data)
        }

        @Test
        func `fsync sets opcode and datasync flag`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 1
            entry.fsync(target: .registered(3), datasync: true, data: data)
            #expect(entry.opcode == .sync.file.standard)
            #expect(entry.cValue.fd == 3)
            #expect(entry.opFlags == 1)
            #expect(entry.data == data)
        }

        @Test
        func `close sets opcode and target`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 5
            entry.close(target: .registered(10), data: data)
            #expect(entry.opcode == .close)
            #expect(entry.cValue.fd == 10)
            #expect(entry.data == data)
        }
    }

    // MARK: - File I/O (Fixed, Multishot)

    extension Kernel.IO.Uring.Submission.Queue.Entry.PrepareTest.Unit {
        @Test
        func `read fixed sets opcode and buffer index`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 20
            let buf = unsafe UnsafeMutableRawPointer(bitPattern: 0x2000)!
            unsafe entry.read(
                target: .registered(8),
                buffer: buf,
                length: 1024,
                offset: .zero,
                bufferIndex: 3,
                data: data
            )
            #expect(entry.opcode == .read.fixed)
            #expect(entry.addr == 0x2000)
            #expect(entry.len == 1024)
            #expect(entry.cValue.buf_index == 3)
            #expect(entry.data == data)
        }

        @Test
        func `read multishot sets opcode, buffer group, and buffer select flag`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 30
            entry.read(
                target: .registered(2),
                length: 8192,
                offset: .current,
                bufferGroup: 7,
                data: data
            )
            #expect(entry.opcode == .read.multishot)
            #expect(entry.cValue.buf_group == 7)
            #expect(entry.flags.contains(.bufferSelect))
            #expect(entry.len == 8192)
            #expect(entry.data == data)
        }
    }

    // MARK: - File I/O (Truncate)

    extension Kernel.IO.Uring.Submission.Queue.Entry.PrepareTest.Unit {
        @Test
        func `ftruncate sets opcode and length in offset field`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 40
            entry.ftruncate(target: .registered(11), length: 65536, data: data)
            #expect(entry.opcode == .file.ftruncate)
            #expect(entry.offset == 65536)
            #expect(entry.data == data)
        }
    }

    // MARK: - File System

    extension Kernel.IO.Uring.Submission.Queue.Entry.PrepareTest.Unit {
        @Test
        func `unlinkat sets opcode, path, and flags`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 52
            let path = unsafe UnsafePointer<CChar>(bitPattern: 0x7000)!
            unsafe entry.unlinkat(
                target: .registered(2),
                path: path,
                flags: Kernel.File.At.Options(rawValue: Int32(bitPattern: 0x200)),
                data: data
            )
            #expect(entry.opcode == .file.unlinkat)
            #expect(entry.addr == 0x7000)
            #expect(entry.cValue.rw_flags == 0x200)
            #expect(entry.data == data)
        }

        @Test
        func `mkdirat sets opcode, path, and mode`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 53
            let path = unsafe UnsafePointer<CChar>(bitPattern: 0x8000)!
            unsafe entry.mkdirat(target: .registered(3), path: path, mode: 0o755, data: data)
            #expect(entry.opcode == .file.mkdirat)
            #expect(entry.addr == 0x8000)
            #expect(entry.cValue.len == 0o755)
            #expect(entry.data == data)
        }
    }

    // MARK: - Networking

    extension Kernel.IO.Uring.Submission.Queue.Entry.PrepareTest.Unit {
        @Test
        func `socket sets domain in fd, protocol in len, kind in off`() {
            typealias SocketProtocol = Kernel.Socket.`Protocol`
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 60
            entry.socket(
                domain: Kernel.Socket.Address.Family(rawValue: 2),
                kind: Kernel.Socket.Kind(rawValue: 1),
                protocol: SocketProtocol(rawValue: 6),
                flags: Kernel.Socket.Options(rawValue: 0),
                data: data
            )
            #expect(entry.opcode == .socket.create)
            #expect(entry.cValue.fd == 2)
            #expect(entry.cValue.len == UInt32(bitPattern: 6))
            #expect(entry.cValue.off == 1)
            #expect(entry.data == data)
        }

        @Test
        func `listen sets opcode and backlog`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 62
            entry.listen(target: .registered(13), backlog: 128, data: data)
            #expect(entry.opcode == .socket.listen)
            #expect(entry.cValue.off == 128)
            #expect(entry.data == data)
        }

        @Test
        func `shutdown sets opcode and mode`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 63
            entry.shutdown(
                target: .registered(14),
                how: Kernel.Socket.Shutdown.Mode(rawValue: 2),
                data: data
            )
            #expect(entry.opcode == .socket.shutdown)
            #expect(entry.cValue.len == UInt32(bitPattern: 2))
            #expect(entry.data == data)
        }
    }

    // MARK: - Timeout and Poll

    extension Kernel.IO.Uring.Submission.Queue.Entry.PrepareTest.Unit {
        @Test
        func `timeout remove sets opcode, target data, and fd to -1`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let target: Kernel.IO.Uring.Operation.Data = 0xAAAA
            let data: Kernel.IO.Uring.Operation.Data = 70
            entry.timeout(remove: target, data: data)
            #expect(entry.opcode == .timeout.remove)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0xAAAA)
            #expect(entry.data == data)
        }

        @Test
        func `poll remove sets opcode and target data`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let target: Kernel.IO.Uring.Operation.Data = 0xBBBB
            let data: Kernel.IO.Uring.Operation.Data = 72
            entry.poll(remove: target, data: data)
            #expect(entry.opcode == .poll.remove)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0xBBBB)
            #expect(entry.data == data)
        }
    }

    // MARK: - Control and Utility

    extension Kernel.IO.Uring.Submission.Queue.Entry.PrepareTest.Unit {
        @Test
        func `message ring sets opcode, target ring fd, value, and target data`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let targetData: Kernel.IO.Uring.Operation.Data = 0xF00D
            let data: Kernel.IO.Uring.Operation.Data = 80
            entry.message(
                ring: 5,
                value: 42,
                targetData: targetData,
                flags: Kernel.IO.Uring.Message.Options(rawValue: 0),
                data: data
            )
            #expect(entry.opcode == .ring.msg)
            #expect(entry.cValue.fd == 5)
            #expect(entry.cValue.len == 42)
            #expect(entry.cValue.off == 0xF00D)
            #expect(entry.data == data)
        }

        @Test
        func `provide buffers sets opcode, fd as count, buffer group, and start id`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 81
            let buf = unsafe UnsafeRawPointer(bitPattern: 0xD000)!
            unsafe entry.provide(buffer: buf, length: 4096, count: 16, group: 3, startId: 100, data: data)
            #expect(entry.opcode == .buffer.provide)
            #expect(entry.cValue.fd == 16)
            #expect(entry.addr == 0xD000)
            #expect(entry.len == 4096)
            #expect(entry.cValue.off == 100)
            #expect(entry.cValue.buf_group == 3)
            #expect(entry.data == data)
        }

        @Test
        func `remove buffers sets opcode, fd as count, and buffer group`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 82
            entry.remove(bufferCount: 8, group: 5, data: data)
            #expect(entry.opcode == .buffer.remove)
            #expect(entry.cValue.fd == 8)
            #expect(entry.cValue.buf_group == 5)
            #expect(entry.data == data)
        }

        @Test
        func `uring command sets opcode and cmd op`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 83
            entry.command(target: .registered(25), op: 0x7F, data: data)
            #expect(entry.opcode == .ring.cmd)
            #expect(entry.cValue.cmd_op == 0x7F)
            #expect(entry.data == data)
        }

        @Test
        func `install fd sets opcode and flags`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 84
            entry.install(fd: 10, flags: Kernel.IO.Uring.Fixed.Install.Options(rawValue: 0x01), data: data)
            #expect(entry.opcode == .fixed.install)
            #expect(entry.cValue.fd == 10)
            #expect(entry.cValue.rw_flags == 0x01)
            #expect(entry.data == data)
        }

        @Test
        func `pipe sets opcode and fd to -1`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 85
            let fds = unsafe UnsafeMutablePointer<Int32>(bitPattern: 0xE000)!
            unsafe entry.pipe(fds: fds, flags: Kernel.Pipe.Options(rawValue: Int32(bitPattern: 0x80000)), data: data)
            #expect(entry.opcode == .pipe.create)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0xE000)
            #expect(entry.cValue.rw_flags == 0x80000)
            #expect(entry.data == data)
        }

        @Test
        func `nop128 sets opcode`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 86
            entry.nop128(data: data)
            #expect(entry.opcode == .nop128)
            #expect(entry.data == data)
        }

        @Test
        func `files update sets opcode, fds addr, count, and offset`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 88
            let fds = unsafe UnsafePointer<Int32>(bitPattern: 0x1100)!
            unsafe entry.files(update: fds, count: 4, offset: 10, data: data)
            #expect(entry.opcode == .file.update)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0x1100)
            #expect(entry.cValue.len == 4)
            #expect(entry.cValue.off == 10)
            #expect(entry.data == data)
        }
    }

    // MARK: - File and Memory Advisory

    extension Kernel.IO.Uring.Submission.Queue.Entry.PrepareTest.Unit {
        @Test
        func `fadvise sets opcode, offset, length, and advice`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 90
            entry.fadvise(
                target: .registered(30),
                offset: .zero,
                length: 0,
                advice: Kernel.File.Advice(rawValue: 2),
                data: data
            )
            #expect(entry.opcode == .file.fadvise)
            #expect(entry.cValue.rw_flags == 2)
            #expect(entry.data == data)
        }

        @Test
        func `madvise sets opcode, addr, length, advice, and fd to -1`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data: Kernel.IO.Uring.Operation.Data = 91
            let addr = unsafe UnsafeMutableRawPointer(bitPattern: 0x10000)!
            unsafe entry.madvise(addr: addr, length: 4096, advice: Memory.Map.Advice(rawValue: 4), data: data)
            #expect(entry.opcode == .memory.madvise)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0x10000)
            #expect(entry.len == 4096)
            #expect(entry.cValue.rw_flags == 4)
            #expect(entry.data == data)
        }
    }

    // MARK: - Zero-Initialization Safety

    extension Kernel.IO.Uring.Submission.Queue.Entry.PrepareTest.Unit {
        @Test
        func `mutating methods zero-initialize before setting fields`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()

            // First: set many fields via a complex operation
            let buf = unsafe UnsafeMutableRawPointer(bitPattern: 0x5000)!
            unsafe entry.read(target: .registered(99), buffer: buf, length: 4096, offset: 1000, data: 1)
            #expect(entry.cValue.fd == 99)
            #expect(entry.addr == 0x5000)

            // Then: overwrite with nop — all previous fields must be zeroed
            entry.nop(data: 2)
            #expect(entry.opcode == .nop)
            #expect(entry.data == 2)
            #expect(entry.cValue.fd == 0)
            #expect(entry.addr == 0)
            #expect(entry.cValue.len == 0)
            #expect(entry.cValue.off == 0)
        }
    }

#endif
