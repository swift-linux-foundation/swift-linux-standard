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

    import Kernel_Primitives_Core
    import Kernel_Event_Primitives
    import Kernel_IO_Primitives
    import Kernel_Descriptor_Primitives
    import Kernel_Error_Primitives
    import Kernel_File_Primitives
    import Kernel_Memory_Primitives
    @testable import Linux_Kernel_Standard

    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        enum Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Existing Operations

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `nop sets opcode and data`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 42)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.nop(data: data)
            }
            #expect(entry.opcode == .nop)
            #expect(entry.data == data)
        }

        @Test
        func `read sets opcode, target, buffer addr, length, and offset`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 99)
            let buf = unsafe UnsafeMutableRawPointer(bitPattern: 0x1000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.read(
                    target: .registered(7),
                    buffer: buf,
                    length: Kernel.IO.Uring.Length(4096),
                    offset: Kernel.IO.Uring.Offset(200),
                    data: data
                )
            }
            #expect(entry.opcode == .read.standard)
            #expect(entry.cValue.fd == 7)
            #expect(entry.flags.contains(.fixedFile))
            #expect(entry.addr == 0x1000)
            #expect(entry.len == Kernel.IO.Uring.Length(4096))
            #expect(entry.offset == Kernel.IO.Uring.Offset(200))
            #expect(entry.data == data)
        }

        @Test
        func `cancel sets opcode and target data`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let cancelTarget = Kernel.IO.Uring.Operation.Data(__unchecked: (), 0xBEEF)
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 0xCAFE)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.cancel(target: cancelTarget, data: data)
            }
            #expect(entry.opcode == .cancel.async)
            #expect(entry.addr == 0xBEEF)
            #expect(entry.data == data)
        }

        @Test
        func `fsync sets opcode and datasync flag`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 1)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.fsync(
                    target: .registered(3),
                    datasync: true,
                    data: data
                )
            }
            #expect(entry.opcode == .sync.file)
            #expect(entry.cValue.fd == 3)
            #expect(entry.opFlags == 1)
            #expect(entry.data == data)
        }

        @Test
        func `close sets opcode and target`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 5)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.close(target: .registered(10), data: data)
            }
            #expect(entry.opcode == .close)
            #expect(entry.cValue.fd == 10)
            #expect(entry.data == data)
        }
    }

    // MARK: - File I/O (Vectored, Fixed, Multishot)

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `read vectored sets opcode, iovec addr, and count`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 10)
            var vec = iovec()
            withUnsafeMutablePointer(to: &entry) { ptr in
                withUnsafePointer(to: &vec) { vecPtr in
                    unsafe ptr.prepare.read(
                        target: .registered(4),
                        vectors: vecPtr,
                        count: 3,
                        offset: Kernel.IO.Uring.Offset(500),
                        data: data
                    )
                }
            }
            #expect(entry.opcode == .read.vectored)
            #expect(entry.cValue.fd == 4)
            #expect(entry.cValue.len == 3)
            #expect(entry.offset == Kernel.IO.Uring.Offset(500))
            #expect(entry.data == data)
        }

        @Test
        func `write vectored sets opcode and count`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 11)
            var vec = iovec()
            withUnsafeMutablePointer(to: &entry) { ptr in
                withUnsafePointer(to: &vec) { vecPtr in
                    unsafe ptr.prepare.write(
                        target: .registered(6),
                        vectors: vecPtr,
                        count: 2,
                        offset: .zero,
                        data: data
                    )
                }
            }
            #expect(entry.opcode == .write.vectored)
            #expect(entry.cValue.len == 2)
            #expect(entry.data == data)
        }

        @Test
        func `read fixed sets opcode and buffer index`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 20)
            let buf = unsafe UnsafeMutableRawPointer(bitPattern: 0x2000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.read(
                    target: .registered(8),
                    buffer: buf,
                    length: Kernel.IO.Uring.Length(1024),
                    offset: .zero,
                    bufferIndex: Kernel.IO.Uring.Buffer.Index(3),
                    data: data
                )
            }
            #expect(entry.opcode == .read.fixed)
            #expect(entry.addr == 0x2000)
            #expect(entry.len == Kernel.IO.Uring.Length(1024))
            #expect(entry.cValue.buf_index == 3)
            #expect(entry.data == data)
        }

        @Test
        func `write fixed sets opcode and buffer index`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 21)
            let buf = unsafe UnsafeRawPointer(bitPattern: 0x3000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.write(
                    target: .registered(9),
                    buffer: buf,
                    length: Kernel.IO.Uring.Length(512),
                    offset: .zero,
                    bufferIndex: Kernel.IO.Uring.Buffer.Index(5),
                    data: data
                )
            }
            #expect(entry.opcode == .write.fixed)
            #expect(entry.cValue.buf_index == 5)
            #expect(entry.data == data)
        }

        @Test
        func `read multishot sets opcode, buffer group, and buffer select flag`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 30)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.read(
                    target: .registered(2),
                    length: Kernel.IO.Uring.Length(8192),
                    offset: .current,
                    bufferGroup: Kernel.IO.Uring.Buffer.Group(7),
                    data: data
                )
            }
            #expect(entry.opcode == .read.multishot)
            #expect(entry.cValue.buf_group == 7)
            #expect(entry.flags.contains(.bufferSelect))
            #expect(entry.len == Kernel.IO.Uring.Length(8192))
            #expect(entry.data == data)
        }
    }

    // MARK: - File I/O (Truncate)

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `ftruncate sets opcode and length in offset field`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 40)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.ftruncate(
                    target: .registered(11),
                    length: Kernel.IO.Uring.Offset(65536),
                    data: data
                )
            }
            #expect(entry.opcode == .file.ftruncate)
            #expect(entry.offset == Kernel.IO.Uring.Offset(65536))
            #expect(entry.data == data)
        }
    }

    // MARK: - File System

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `openat sets opcode, path, flags, and mode`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 50)
            let path = unsafe UnsafePointer<CChar>(bitPattern: 0x4000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.openat(
                    target: .registered(5),
                    path: path,
                    flags: 0x42,
                    mode: 0o755,
                    data: data
                )
            }
            #expect(entry.opcode == .file.openat)
            #expect(entry.addr == 0x4000)
            #expect(entry.opFlags == 0x42)
            #expect(entry.cValue.len == 0o755)
            #expect(entry.data == data)
        }

        @Test
        func `statx sets opcode, path, flags, mask, and buffer`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 51)
            let path = unsafe UnsafePointer<CChar>(bitPattern: 0x5000)!
            let statxBuf = unsafe UnsafeMutableRawPointer(bitPattern: 0x6000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.statx(
                    target: .registered(1),
                    path: path,
                    flags: 0x100,
                    mask: 0xFF,
                    buffer: statxBuf,
                    data: data
                )
            }
            #expect(entry.opcode == .file.statx)
            #expect(entry.addr == 0x5000)
            #expect(entry.cValue.rw_flags == 0x100)
            #expect(entry.cValue.len == 0xFF)
            #expect(entry.cValue.off == 0x6000)
            #expect(entry.data == data)
        }

        @Test
        func `unlinkat sets opcode, path, and flags`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 52)
            let path = unsafe UnsafePointer<CChar>(bitPattern: 0x7000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.unlinkat(
                    target: .registered(2),
                    path: path,
                    flags: 0x200,
                    data: data
                )
            }
            #expect(entry.opcode == .file.unlinkat)
            #expect(entry.addr == 0x7000)
            #expect(entry.cValue.rw_flags == 0x200)
            #expect(entry.data == data)
        }

        @Test
        func `mkdirat sets opcode, path, and mode`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 53)
            let path = unsafe UnsafePointer<CChar>(bitPattern: 0x8000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.mkdirat(
                    target: .registered(3),
                    path: path,
                    mode: 0o755,
                    data: data
                )
            }
            #expect(entry.opcode == .file.mkdirat)
            #expect(entry.addr == 0x8000)
            #expect(entry.cValue.len == 0o755)
            #expect(entry.data == data)
        }

        @Test
        func `fallocate stores length in addr field`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 54)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.fallocate(
                    target: .registered(4),
                    mode: 0x01,
                    offset: Kernel.IO.Uring.Offset(1000),
                    length: 0x1_0000_0000,
                    data: data
                )
            }
            #expect(entry.opcode == .file.fallocate)
            #expect(entry.addr == 0x1_0000_0000)
            #expect(entry.offset == Kernel.IO.Uring.Offset(1000))
            #expect(entry.cValue.len == 0x01)
            #expect(entry.data == data)
        }
    }

    // MARK: - Networking

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `socket sets domain in fd, protocol in len, type in off`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 60)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.socket(
                    domain: 2,
                    type: 1,
                    protocol: 6,
                    flags: 0,
                    data: data
                )
            }
            #expect(entry.opcode == .socket.create)
            #expect(entry.cValue.fd == 2)
            #expect(entry.cValue.len == 6)
            #expect(entry.cValue.off == 1)
            #expect(entry.data == data)
        }

        @Test
        func `bind sets opcode, addr, and addr length`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 61)
            let addr = unsafe UnsafeRawPointer(bitPattern: 0x9000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.bind(
                    target: .registered(12),
                    addr: addr,
                    addrLen: 16,
                    data: data
                )
            }
            #expect(entry.opcode == .socket.bind)
            #expect(entry.addr == 0x9000)
            #expect(entry.cValue.off == 16)
            #expect(entry.data == data)
        }

        @Test
        func `listen sets opcode and backlog`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 62)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.listen(
                    target: .registered(13),
                    backlog: 128,
                    data: data
                )
            }
            #expect(entry.opcode == .socket.listen)
            #expect(entry.cValue.off == 128)
            #expect(entry.data == data)
        }

        @Test
        func `shutdown sets opcode and how`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 63)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.shutdown(
                    target: .registered(14),
                    how: 2,
                    data: data
                )
            }
            #expect(entry.opcode == .socket.shutdown)
            #expect(entry.cValue.len == UInt32(bitPattern: 2))
            #expect(entry.data == data)
        }

        @Test
        func `send zero copy sets opcode and zero copy flags in priority`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 64)
            let buf = unsafe UnsafeRawPointer(bitPattern: 0xA000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.send(
                    target: .registered(15),
                    buffer: buf,
                    length: Kernel.IO.Uring.Length(256),
                    flags: 0x40,
                    zeroCopyFlags: Kernel.IO.Uring.Priority(1),
                    data: data
                )
            }
            #expect(entry.opcode == .send.zero.copy)
            #expect(entry.addr == 0xA000)
            #expect(entry.len == Kernel.IO.Uring.Length(256))
            #expect(entry.opFlags == 0x40)
            #expect(entry.priority == Kernel.IO.Uring.Priority(1))
            #expect(entry.data == data)
        }

        @Test
        func `epoll ctl sets opcode, epoll fd, target fd, op, and event`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 65)
            let event = unsafe UnsafeMutableRawPointer(bitPattern: 0xB000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.epoll(
                    target: .registered(16),
                    fd: 42,
                    op: 1,
                    event: event,
                    data: data
                )
            }
            #expect(entry.opcode == .epoll.ctl)
            #expect(entry.addr == 0xB000)
            #expect(entry.cValue.len == 1)
            #expect(entry.cValue.off == 42)
            #expect(entry.data == data)
        }

        @Test
        func `epoll wait sets opcode, events buffer, and max events`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 66)
            let events = unsafe UnsafeMutableRawPointer(bitPattern: 0xC000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.epoll(
                    target: .registered(17),
                    events: events,
                    maxEvents: 64,
                    data: data
                )
            }
            #expect(entry.opcode == .epoll.wait)
            #expect(entry.addr == 0xC000)
            #expect(entry.cValue.len == 64)
            #expect(entry.data == data)
        }
    }

    // MARK: - Timeout and Poll

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `timeout remove sets opcode, target data, and fd to -1`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let target = Kernel.IO.Uring.Operation.Data(__unchecked: (), 0xAAAA)
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 70)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.timeout(remove: target, flags: 0x01, data: data)
            }
            #expect(entry.opcode == .timeout.remove)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0xAAAA)
            #expect(entry.cValue.rw_flags == 0x01)
            #expect(entry.data == data)
        }

        @Test
        func `poll add sets opcode, mask, and flags`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 71)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.poll(
                    target: .registered(20),
                    mask: 0x0001,
                    flags: 0x01,
                    data: data
                )
            }
            #expect(entry.opcode == .poll.add)
            #expect(entry.cValue.poll32_events == 0x0001)
            #expect(entry.cValue.len == 0x01)
            #expect(entry.data == data)
        }

        @Test
        func `poll remove sets opcode and target data`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let target = Kernel.IO.Uring.Operation.Data(__unchecked: (), 0xBBBB)
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 72)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.poll(remove: target, data: data)
            }
            #expect(entry.opcode == .poll.remove)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0xBBBB)
            #expect(entry.data == data)
        }
    }

    // MARK: - Control and Utility

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `message ring sets opcode, target ring fd, value, and target data`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let targetData = Kernel.IO.Uring.Operation.Data(__unchecked: (), 0xF00D)
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 80)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.message(
                    ring: 5,
                    value: 42,
                    targetData: targetData,
                    flags: 0,
                    data: data
                )
            }
            #expect(entry.opcode == .ring.msg)
            #expect(entry.cValue.fd == 5)
            #expect(entry.cValue.len == 42)
            #expect(entry.cValue.off == 0xF00D)
            #expect(entry.data == data)
        }

        @Test
        func `provide buffers sets opcode, fd as count, buffer group, and start id`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 81)
            let buf = unsafe UnsafeRawPointer(bitPattern: 0xD000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.provide(
                    buffer: buf,
                    length: Kernel.IO.Uring.Length(4096),
                    count: 16,
                    group: Kernel.IO.Uring.Buffer.Group(3),
                    startId: 100,
                    data: data
                )
            }
            #expect(entry.opcode == .buffer.provide)
            #expect(entry.cValue.fd == 16)
            #expect(entry.addr == 0xD000)
            #expect(entry.len == Kernel.IO.Uring.Length(4096))
            #expect(entry.cValue.off == 100)
            #expect(entry.cValue.buf_group == 3)
            #expect(entry.data == data)
        }

        @Test
        func `remove buffers sets opcode, fd as count, and buffer group`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 82)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.remove(
                    bufferCount: 8,
                    group: Kernel.IO.Uring.Buffer.Group(5),
                    data: data
                )
            }
            #expect(entry.opcode == .buffer.remove)
            #expect(entry.cValue.fd == 8)
            #expect(entry.cValue.buf_group == 5)
            #expect(entry.data == data)
        }

        @Test
        func `uring command sets opcode and cmd op`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 83)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.command(
                    target: .registered(25),
                    op: 0x7F,
                    data: data
                )
            }
            #expect(entry.opcode == .ring.cmd)
            #expect(entry.cValue.cmd_op == 0x7F)
            #expect(entry.data == data)
        }

        @Test
        func `install fd sets opcode and flags`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 84)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.install(fd: 10, flags: 0x01, data: data)
            }
            #expect(entry.opcode == .fixed.fdInstall)
            #expect(entry.cValue.fd == 10)
            #expect(entry.cValue.rw_flags == 0x01)
            #expect(entry.data == data)
        }

        @Test
        func `pipe sets opcode and fd to -1`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 85)
            let fds = unsafe UnsafeMutablePointer<Int32>(bitPattern: 0xE000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.pipe(fds: fds, flags: 0x80000, data: data)
            }
            #expect(entry.opcode == .pipe.create)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0xE000)
            #expect(entry.cValue.rw_flags == 0x80000)
            #expect(entry.data == data)
        }

        @Test
        func `nop128 sets opcode`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 86)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.nop128(data: data)
            }
            #expect(entry.opcode == .nop128)
            #expect(entry.data == data)
        }

        @Test
        func `waitid sets opcode, idtype, id, and options`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 87)
            let info = unsafe UnsafeMutableRawPointer(bitPattern: 0xF000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.waitid(
                    idtype: 1,
                    id: 42,
                    info: info,
                    options: 0x04,
                    flags: 0,
                    data: data
                )
            }
            #expect(entry.opcode == .wait.id)
            #expect(entry.cValue.fd == 42)
            #expect(entry.cValue.len == 1)
            #expect(entry.cValue.off == 0xF000)
            #expect(entry.cValue.file_index == 0x04)
            #expect(entry.data == data)
        }

        @Test
        func `files update sets opcode, fds addr, count, and offset`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 88)
            let fds = unsafe UnsafePointer<Int32>(bitPattern: 0x1100)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.files(
                    update: fds,
                    count: 4,
                    offset: 10,
                    data: data
                )
            }
            #expect(entry.opcode == .file.filesUpdate)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0x1100)
            #expect(entry.cValue.len == 4)
            #expect(entry.cValue.off == 10)
            #expect(entry.data == data)
        }
    }

    // MARK: - File and Memory Advisory

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `fadvise sets opcode, offset, length, and advice`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 90)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.fadvise(
                    target: .registered(30),
                    offset: Kernel.IO.Uring.Offset(0),
                    length: Kernel.IO.Uring.Length(0),
                    advice: 2,
                    data: data
                )
            }
            #expect(entry.opcode == .file.fadvise)
            #expect(entry.cValue.rw_flags == 2)
            #expect(entry.data == data)
        }

        @Test
        func `madvise sets opcode, addr, length, advice, and fd to -1`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 91)
            let addr = unsafe UnsafeMutableRawPointer(bitPattern: 0x10000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.madvise(
                    addr: addr,
                    length: Kernel.IO.Uring.Length(4096),
                    advice: 4,
                    data: data
                )
            }
            #expect(entry.opcode == .memory.madvise)
            #expect(entry.cValue.fd == -1)
            #expect(entry.addr == 0x10000)
            #expect(entry.len == Kernel.IO.Uring.Length(4096))
            #expect(entry.cValue.rw_flags == 4)
            #expect(entry.data == data)
        }

        @Test
        func `sync file range sets opcode, offset, length, and flags`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 92)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.sync(
                    target: .registered(31),
                    offset: Kernel.IO.Uring.Offset(4096),
                    length: Kernel.IO.Uring.Length(8192),
                    flags: 0x02,
                    data: data
                )
            }
            #expect(entry.opcode == .sync.fileRange)
            #expect(entry.offset == Kernel.IO.Uring.Offset(4096))
            #expect(entry.len == Kernel.IO.Uring.Length(8192))
            #expect(entry.cValue.rw_flags == 0x02)
            #expect(entry.data == data)
        }
    }

    // MARK: - Futex

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `futex wait sets opcode, futex addr, value, mask in addr3, and fd to 0`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 100)
            let futex = unsafe UnsafePointer<UInt32>(bitPattern: 0x2000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.futex(
                    wait: futex,
                    value: 1,
                    mask: 0xFFFF_FFFF,
                    flags: 0,
                    data: data
                )
            }
            #expect(entry.opcode == .futex.wait)
            #expect(entry.cValue.fd == 0)
            #expect(entry.addr == 0x2000)
            #expect(entry.cValue.off == 1)
            #expect(entry.cValue.addr3 == 0xFFFF_FFFF)
            #expect(entry.data == data)
        }

        @Test
        func `futex wake sets opcode and value`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 101)
            let futex = unsafe UnsafePointer<UInt32>(bitPattern: 0x3000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.futex(
                    wake: futex,
                    value: 1,
                    mask: 0xFFFF_FFFF,
                    flags: 0,
                    data: data
                )
            }
            #expect(entry.opcode == .futex.wake)
            #expect(entry.addr == 0x3000)
            #expect(entry.cValue.off == 1)
            #expect(entry.data == data)
        }
    }

    // MARK: - Extended Attributes

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.Unit {
        @Test
        func `fsetxattr sets opcode, name, value addr, length, and flags`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 110)
            let name = unsafe UnsafePointer<CChar>(bitPattern: 0x4000)!
            let value = unsafe UnsafeRawPointer(bitPattern: 0x5000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.fsetxattr(
                    target: .registered(40),
                    name: name,
                    value: value,
                    length: Kernel.IO.Uring.Length(64),
                    flags: 0x01,
                    data: data
                )
            }
            #expect(entry.opcode == .xattr.fset)
            #expect(entry.addr == 0x4000)
            #expect(entry.cValue.off == 0x5000)
            #expect(entry.len == Kernel.IO.Uring.Length(64))
            #expect(entry.cValue.rw_flags == 0x01)
            #expect(entry.data == data)
        }

        @Test
        func `getxattr sets opcode, name, value, path in addr3, and fd to 0`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 111)
            let name = unsafe UnsafePointer<CChar>(bitPattern: 0x6000)!
            let value = unsafe UnsafeMutableRawPointer(bitPattern: 0x7000)!
            let path = unsafe UnsafePointer<CChar>(bitPattern: 0x8000)!
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.getxattr(
                    name: name,
                    value: value,
                    path: path,
                    length: Kernel.IO.Uring.Length(256),
                    data: data
                )
            }
            #expect(entry.opcode == .xattr.get)
            #expect(entry.cValue.fd == 0)
            #expect(entry.addr == 0x6000)
            #expect(entry.cValue.off == 0x7000)
            #expect(entry.cValue.addr3 == 0x8000)
            #expect(entry.len == Kernel.IO.Uring.Length(256))
            #expect(entry.data == data)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare.Test.`Edge Case` {
        @Test
        func `prep function zeros SQE before setting fields`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data1 = Kernel.IO.Uring.Operation.Data(__unchecked: (), 0xFF)
            let data2 = Kernel.IO.Uring.Operation.Data(__unchecked: (), 0x01)

            // First: set up a complex operation
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.poll(
                    target: .registered(99),
                    mask: 0xFFFF,
                    flags: 0xFF,
                    data: data1
                )
            }
            #expect(entry.cValue.fd == 99)
            #expect(entry.cValue.poll32_events == 0xFFFF)

            // Second: overwrite with a simple nop — all prior fields must be zero
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.nop(data: data2)
            }
            #expect(entry.opcode == .nop)
            #expect(entry.cValue.fd == 0)
            #expect(entry.cValue.poll32_events == 0)
            #expect(entry.cValue.len == 0)
            #expect(entry.addr == 0)
            #expect(entry.data == data2)
        }

        @Test
        func `registered target sets fixed file flag`() {
            var entry = Kernel.IO.Uring.Submission.Queue.Entry()
            let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), 1)
            withUnsafeMutablePointer(to: &entry) { ptr in
                unsafe ptr.prepare.close(target: .registered(50), data: data)
            }
            #expect(entry.flags.contains(.fixedFile))
            #expect(entry.cValue.fd == 50)
        }
    }
#endif
