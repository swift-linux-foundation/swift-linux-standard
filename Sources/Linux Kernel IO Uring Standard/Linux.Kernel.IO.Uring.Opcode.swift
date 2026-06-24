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

public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {
        /// Opcodes specifying which operation to submit to io_uring.
        ///
        /// Each opcode corresponds to an `IORING_OP_*` constant from `<linux/io_uring.h>`.
        /// When preparing a submission queue entry (SQE), the opcode determines what
        /// the kernel will do when processing that entry.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Prepare a read operation
        /// sqe.opcode = .read.standard
        /// sqe.fd = fd.rawValue
        /// sqe.addr = UInt64(UInt(bitPattern: buffer.baseAddress))
        /// sqe.len = UInt32(buffer.count)
        /// sqe.off = offset
        /// ```
        ///
        /// ## Kernel Version Requirements
        ///
        /// Some opcodes require newer kernel versions:
        /// - `.read.standard`/`.write.standard`: 5.6+
        /// - `.send.zero.copy`: 6.0+
        /// - `.futex.wait`/`.futex.wake`: 6.7+
        /// - `.file.ftruncate`: 6.9+
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring``
        /// - ``Kernel/IO/Uring/Submission``
        public struct Opcode: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt8

            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
        }
    }

    // MARK: - Basic Operations

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// No operation (used for wakeup or testing).
        public static let nop = Self(rawValue: 0)

        /// Close file descriptor.
        public static let close = Self(rawValue: 19)

        /// 128-byte no-op (kernel 6.13+).
        // TRACKING: Opcode 63 exceeds IORING_OP_LAST=58 in kernel 6.12.
        public static let nop128 = Self(rawValue: 63)
    }

    // MARK: - CustomStringConvertible

    extension ISO_9945.Kernel.IO.Uring.Opcode: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            // Basic
            case .nop: return "NOP"
            case .close: return "CLOSE"
            case .nop128: return "NOP128"
            // Read
            case .read.standard: return "READ"
            case .read.vectored.standard: return "READV"
            case .read.vectored.fixed: return "READV_FIXED"
            case .read.fixed: return "READ_FIXED"
            case .read.multishot: return "READ_MULTISHOT"
            // Write
            case .write.standard: return "WRITE"
            case .write.vectored.standard: return "WRITEV"
            case .write.vectored.fixed: return "WRITEV_FIXED"
            case .write.fixed: return "WRITE_FIXED"
            // Sync
            case .sync.file.standard: return "FSYNC"
            case .sync.file.range: return "SYNC_FILE_RANGE"
            // File
            case .file.openat: return "OPENAT"
            case .file.openat2: return "OPENAT2"
            case .file.statx: return "STATX"
            case .file.fallocate: return "FALLOCATE"
            case .file.fadvise: return "FADVISE"
            case .file.ftruncate: return "FTRUNCATE"
            case .file.renameat: return "RENAMEAT"
            case .file.unlinkat: return "UNLINKAT"
            case .file.mkdirat: return "MKDIRAT"
            case .file.symlinkat: return "SYMLINKAT"
            case .file.linkat: return "LINKAT"
            case .file.update: return "FILES_UPDATE"
            // Socket
            case .socket.accept: return "ACCEPT"
            case .socket.connect: return "CONNECT"
            case .socket.send: return "SEND"
            case .socket.receive: return "RECV"
            case .socket.message.send: return "SENDMSG"
            case .socket.message.receive: return "RECVMSG"
            case .socket.shutdown: return "SHUTDOWN"
            case .socket.create: return "SOCKET"
            case .socket.bind: return "BIND"
            case .socket.listen: return "LISTEN"
            case .socket.receiveZeroCopy: return "RECV_ZC"
            // Send (zero-copy)
            case .send.zero.copy: return "SEND_ZC"
            case .send.zero.msg: return "SENDMSG_ZC"
            // Cancel
            case .cancel.async: return "ASYNC_CANCEL"
            // Timeout
            case .timeout.standard: return "TIMEOUT"
            case .timeout.remove: return "TIMEOUT_REMOVE"
            case .timeout.link: return "LINK_TIMEOUT"
            // Poll
            case .poll.add: return "POLL_ADD"
            case .poll.remove: return "POLL_REMOVE"
            // Pipe
            case .pipe.splice: return "SPLICE"
            case .pipe.tee: return "TEE"
            case .pipe.create: return "PIPE"
            // Buffer
            case .buffer.provide: return "PROVIDE_BUFFERS"
            case .buffer.remove: return "REMOVE_BUFFERS"
            // Epoll
            case .epoll.ctl: return "EPOLL_CTL"
            case .epoll.wait: return "EPOLL_WAIT"
            // Ring
            case .ring.msg: return "MSG_RING"
            case .ring.cmd: return "URING_CMD"
            case .ring.cmd128: return "URING_CMD128"
            // Xattr
            case .xattr.fset: return "FSETXATTR"
            case .xattr.set: return "SETXATTR"
            case .xattr.fget: return "FGETXATTR"
            case .xattr.get: return "GETXATTR"
            // Memory
            case .memory.madvise: return "MADVISE"
            // Futex
            case .futex.wait: return "FUTEX_WAIT"
            case .futex.wake: return "FUTEX_WAKE"
            case .futex.waitv: return "FUTEX_WAITV"
            // Wait
            case .wait.id: return "WAITID"
            // Fixed
            case .fixed.install: return "FIXED_FD_INSTALL"
            default: return "OPCODE(\(rawValue))"
            }
        }
    }

#endif
