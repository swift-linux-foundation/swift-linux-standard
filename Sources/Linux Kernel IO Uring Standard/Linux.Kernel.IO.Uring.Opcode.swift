#if os(Linux)

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring {

        public struct Opcode: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt8

            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {

        public static let nop = Self(rawValue: 0)

        public static let close = Self(rawValue: 19)

        public static let nop128 = Self(rawValue: 63)
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode: CustomStringConvertible {
        public var description: Swift.String {
            switch self {

            case .nop: return "NOP"
            case .close: return "CLOSE"
            case .nop128: return "NOP128"

            case .read.standard: return "READ"
            case .read.vectored.standard: return "READV"
            case .read.vectored.fixed: return "READV_FIXED"
            case .read.fixed: return "READ_FIXED"
            case .read.multishot: return "READ_MULTISHOT"

            case .write.standard: return "WRITE"
            case .write.vectored.standard: return "WRITEV"
            case .write.vectored.fixed: return "WRITEV_FIXED"
            case .write.fixed: return "WRITE_FIXED"

            case .sync.file.standard: return "FSYNC"
            case .sync.file.range: return "SYNC_FILE_RANGE"

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

            case .send.zero.copy: return "SEND_ZC"
            case .send.zero.msg: return "SENDMSG_ZC"

            case .cancel.async: return "ASYNC_CANCEL"

            case .timeout.standard: return "TIMEOUT"
            case .timeout.remove: return "TIMEOUT_REMOVE"
            case .timeout.link: return "LINK_TIMEOUT"

            case .poll.add: return "POLL_ADD"
            case .poll.remove: return "POLL_REMOVE"

            case .pipe.splice: return "SPLICE"
            case .pipe.tee: return "TEE"
            case .pipe.create: return "PIPE"

            case .buffer.provide: return "PROVIDE_BUFFERS"
            case .buffer.remove: return "REMOVE_BUFFERS"

            case .epoll.ctl: return "EPOLL_CTL"
            case .epoll.wait: return "EPOLL_WAIT"

            case .ring.msg: return "MSG_RING"
            case .ring.cmd: return "URING_CMD"
            case .ring.cmd128: return "URING_CMD128"

            case .xattr.fset: return "FSETXATTR"
            case .xattr.set: return "SETXATTR"
            case .xattr.fget: return "FGETXATTR"
            case .xattr.get: return "GETXATTR"

            case .memory.madvise: return "MADVISE"

            case .futex.wait: return "FUTEX_WAIT"
            case .futex.wake: return "FUTEX_WAKE"
            case .futex.waitv: return "FUTEX_WAITV"

            case .wait.id: return "WAITID"

            case .fixed.install: return "FIXED_FD_INSTALL"

            default: return "OPCODE(\(rawValue))"
            }
        }
    }

#endif
