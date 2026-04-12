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
    @_spi(Syscall) public import Kernel_IO_Primitives
    @_spi(Syscall) public import Kernel_Descriptor_Primitives
    @_spi(Syscall) public import Kernel_Error_Primitives
    @_spi(Syscall) public import Kernel_Memory_Primitives
    @_spi(Syscall) public import Kernel_File_Primitives
    public import Kernel_Socket_Primitives
    public import Kernel_Event_Primitives
    public import Linux_Kernel_File_Standard
    public import Linux_Kernel_Pipe_Standard
    public import Linux_Kernel_Event_Standard
    public import Linux_Kernel_Futex_Standard
    public import Linux_Kernel_Socket_Standard
    public import Linux_Kernel_Memory_Standard
    public import ISO_9945_Kernel_File

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.Submission.Queue {
        /// Swift wrapper for io_uring submission queue entry.
        ///
        /// An Entry describes an I/O operation to be performed by the kernel.
        /// This wrapper provides a Swift-native interface to the C `io_uring_sqe` struct.
        ///
        /// ## Usage
        ///
        /// Entries are typically filled in-place in the submission queue ring buffer:
        /// ```swift
        /// let entryPtr = ring.sqes.advanced(by: index)
        /// var entry = Kernel.IO.Uring.Submission.Queue.Entry()
        /// entry.setRead(fd: fd, buffer: buffer, offset: 0, data: id)
        /// entryPtr.pointee = entry.cValue
        /// ```
        ///
        /// ## Thread Safety
        ///
        /// Entries are value types that wrap a C struct. They should be filled
        /// on the poll thread and written to the shared ring buffer.
        public struct Entry: Sendable {
            /// The underlying C struct.
            internal var cValue: io_uring_sqe

            /// Creates an empty Entry (zeroed).
            public init() {
                self.cValue = io_uring_sqe()
            }

            /// Creates an Entry from a C struct.
            internal init(_ cValue: io_uring_sqe) {
                self.cValue = cValue
            }
        }
    }

    // MARK: - Accessors

    extension Kernel.IO.Uring.Submission.Queue.Entry {
        /// The operation code.
        public var opcode: Kernel.IO.Uring.Opcode {
            get { Kernel.IO.Uring.Opcode(rawValue: cValue.opcode) }
            set { cValue.opcode = newValue.rawValue }
        }

        /// Entry flags.
        public var flags: Options {
            get { Options(rawValue: cValue.flags) }
            set { cValue.flags = newValue.rawValue }
        }

        /// Operation-specific flags (rw_flags field).
        public var opFlags: Int32 {
            get { Int32(bitPattern: cValue.rw_flags) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue) }
        }

        /// I/O priority.
        public var priority: Kernel.IO.Uring.Priority {
            get { Kernel.IO.Uring.Priority(rawValue: cValue.ioprio) }
            set { cValue.ioprio = newValue.rawValue }
        }

        /// File offset for read/write operations.
        public var offset: Kernel.IO.Uring.Offset {
            get { Kernel.IO.Uring.Offset(cValue.off) }
            set { cValue.off = newValue.rawValue }
        }

        /// Buffer address or other address field.
        public var addr: UInt64 {
            get { cValue.addr }
            set { cValue.addr = newValue }
        }

        /// Buffer length.
        public var len: Kernel.IO.Uring.Length {
            get { Kernel.IO.Uring.Length(cValue.len) }
            set { cValue.len = newValue.rawValue }
        }

        /// Operation data returned with completion.
        public var data: Kernel.IO.Uring.Operation.Data {
            get { Kernel.IO.Uring.Operation.Data(__unchecked: (), cValue.user_data) }
            set { cValue.user_data = newValue.rawValue }
        }

        /// Personality ID (for credentials).
        public var personality: Kernel.IO.Uring.Personality.ID {
            get { Kernel.IO.Uring.Personality.ID(__unchecked: (), cValue.personality) }
            set { cValue.personality = newValue.rawValue }
        }
    }

    // MARK: - Single-Field Semantic Accessors

    // These cover opcodes needing one overloaded field from a union.
    // Multi-field opcodes use view types on Prepare instead.
    // Compound names permitted at @usableFromInline internal scope
    // per feedback_compound_package_scope.

    extension Kernel.IO.Uring.Submission.Queue.Entry {
        /// Unlink AT_* flags (e.g., `AT_REMOVEDIR`).
        @usableFromInline
        internal var atFlags: Kernel.File.At.Options {
            get { Kernel.File.At.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        /// File access pattern advisory hint.
        @usableFromInline
        internal var fileAdvice: Kernel.File.Advice {
            get { Kernel.File.Advice(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        /// Memory advisory hint.
        @usableFromInline
        internal var memoryAdvice: Kernel.Memory.Advice {
            get { Kernel.Memory.Advice(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        /// Sync range flags.
        @usableFromInline
        internal var syncRangeFlags: Kernel.File.Sync.Range.Options {
            get { Kernel.File.Sync.Range.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        /// Pipe creation flags.
        @usableFromInline
        internal var pipeCreateFlags: Kernel.Pipe.Options {
            get { Kernel.Pipe.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        /// Fixed file descriptor installation flags.
        @usableFromInline
        internal var installFlags: Kernel.IO.Uring.Fixed.Install.Options {
            get { Kernel.IO.Uring.Fixed.Install.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        /// File permissions mode (for openat, mkdirat, chmod).
        @usableFromInline
        internal var filePermissions: Kernel.File.Permissions {
            get { Kernel.File.Permissions(rawValue: UInt16(truncatingIfNeeded: cValue.len)) }
            set { cValue.len = UInt32(newValue.rawValue) }
        }

        /// Socket shutdown mode.
        @usableFromInline
        internal var shutdownMode: Kernel.Socket.Shutdown.Mode {
            get { Kernel.Socket.Shutdown.Mode(rawValue: Int32(bitPattern: cValue.len)) }
            set { cValue.len = UInt32(bitPattern: newValue.rawValue) }
        }

        /// Listen backlog (max pending connections).
        @usableFromInline
        internal var listenBacklog: Int32 {
            get { Int32(bitPattern: UInt32(truncatingIfNeeded: cValue.off)) }
            set { cValue.off = UInt64(UInt32(bitPattern: newValue)) }
        }

        /// Socket address length (for bind).
        @usableFromInline
        internal var addressLength: UInt32 {
            get { UInt32(truncatingIfNeeded: cValue.off) }
            set { cValue.off = UInt64(newValue) }
        }

        /// Socket message flags (for send, recv, sendmsg, recvmsg).
        @usableFromInline
        internal var messageFlags: Kernel.Socket.Message.Options {
            get { Kernel.Socket.Message.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        /// Accept flags.
        @usableFromInline
        internal var acceptFlags: Kernel.Socket.Options {
            get { Kernel.Socket.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }
    }

    // MARK: - Raw Field Accessors (Irreducible)

    // For uses where no domain type exists: sentinels, struct sizes,
    // compile-time constants, and misc raw values.

    extension Kernel.IO.Uring.Submission.Queue.Entry {
        /// Fsync datasync-only flag (IORING_FSYNC_DATASYNC).
        @usableFromInline
        internal static let fsyncDatasync: Int32 = Int32(IORING_FSYNC_DATASYNC)

        /// Raw file descriptor field.
        ///
        /// For install registered fd and uring command target only.
        /// Domain-typed uses go through view types or Target.
        @usableFromInline
        internal var _fd: Int32 {
            get { cValue.fd }
            set { cValue.fd = newValue }
        }

        /// Raw length field.
        ///
        /// For openat2 struct size, mkdirat mode, literal 1, and misc counts.
        /// Domain-typed uses go through view types or typed accessors.
        @usableFromInline
        internal var _rawLength: UInt32 {
            get { cValue.len }
            set { cValue.len = newValue }
        }

        /// Raw offset field.
        ///
        /// For openat2 how pointer, symlinkat path, files update offset,
        /// and buffer remove offset. Domain-typed uses go through view types.
        @usableFromInline
        internal var _rawOffset: UInt64 {
            get { cValue.off }
            set { cValue.off = newValue }
        }

        /// Uring command opcode (32-bit union with off).
        @usableFromInline
        internal var commandOpcode: UInt32 {
            get { cValue.cmd_op }
            set { cValue.cmd_op = newValue }
        }
    }

#endif
