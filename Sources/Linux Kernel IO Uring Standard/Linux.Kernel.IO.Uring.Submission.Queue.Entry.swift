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
    public import Kernel_Process_Primitives
    public import ISO_9945_Kernel_File
    public import ISO_9945_Kernel_Process
    public import ISO_9945_Core

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
        /// Entries are filled in-place through the ring's ``Kernel/IO/Uring/Slot``:
        /// ```swift
        /// ring.next.entry.read(target: .descriptor(fd), buffer: buf, length: len, offset: .zero, data: id)
        /// ring.advance()
        /// ```
        ///
        /// ## Ownership
        ///
        /// `~Copyable` — an Entry represents a unique SQE slot. Copying would
        /// create a disconnected value that does not write back to the ring.
        /// Entries are filled in-place through the ``Kernel/IO/Uring/Slot``
        /// coroutine, confined to the io_uring poll thread.
        public struct Entry: ~Copyable {
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
        ///
        /// Raw access for opcodes where the typed union accessors
        /// don't apply (e.g., openat combines access + options).
        @usableFromInline
        internal var opFlags: Int32 {
            get { Int32(bitPattern: cValue.rw_flags) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue) }
        }

        /// I/O priority.
        public var priority: Kernel.IO.Priority {
            get { Kernel.IO.Priority(rawValue: cValue.ioprio) }
            set { cValue.ioprio = newValue.rawValue }
        }

        /// Socket transfer modifier flags (stored in the ioprio field).
        ///
        /// Used by send, recv, sendmsg, recvmsg, send_zc, sendmsg_zc
        /// operations. Overlaps the ioprio field — set one or the other.
        @usableFromInline
        internal var transferOptions: Kernel.IO.Uring.Socket.Transfer.Options {
            get { .init(rawValue: cValue.ioprio) }
            set { cValue.ioprio = newValue.rawValue }
        }

        /// File offset for read/write operations.
        public var offset: Kernel.IO.Uring.Offset {
            get { Kernel.IO.Uring.Offset(cValue.off) }
            set { cValue.off = newValue.rawValue }
        }

        /// Buffer address or other address field.
        ///
        /// Raw UInt64 — used internally by typed `setAddr` helpers
        /// and for irreducible cases (splice offsetIn, fallocate length).
        @usableFromInline
        internal var addr: UInt64 {
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

        /// Registered buffer index.
        @usableFromInline
        internal var _bufferIndex: Kernel.IO.Uring.Buffer.Index {
            get { Kernel.IO.Uring.Buffer.Index(rawValue: cValue.buf_index) }
            set { cValue.buf_index = newValue.rawValue }
        }

        /// Buffer group for kernel-selected buffers.
        @usableFromInline
        internal var _bufferGroup: Kernel.IO.Uring.Buffer.Group {
            get { Kernel.IO.Uring.Buffer.Group(rawValue: cValue.buf_group) }
            set { cValue.buf_group = newValue.rawValue }
        }

        /// Set splice source from a descriptor.
        ///
        /// Absorbs `Kernel.Descriptor._rawValue` extraction — SPI access
        /// hidden from @inlinable callers.
        @usableFromInline
        internal mutating func setSpliceSource(_ descriptor: borrowing Kernel.Descriptor) {
            cValue.splice_fd_in = descriptor._rawValue
        }

        /// Set epoll target descriptor in the offset field.
        ///
        /// Absorbs `Kernel.Descriptor._rawValue` extraction — SPI access
        /// hidden from @inlinable callers.
        @usableFromInline
        internal mutating func setEpollDescriptor(_ descriptor: borrowing Kernel.Descriptor) {
            cValue.off = UInt64(UInt32(bitPattern: descriptor._rawValue))
        }

        /// Third address field (addr3).
        @usableFromInline
        internal var _addr3: UInt64 {
            get { cValue.addr3 }
            set { cValue.addr3 = newValue }
        }

        /// Uring command opcode (32-bit union with off).
        @usableFromInline
        internal var commandOpcode: UInt32 {
            get { cValue.cmd_op }
            set { cValue.cmd_op = newValue }
        }
    }

    // MARK: - Typed Union Accessors (rw_flags domain interpretations)

    // Each opcode interprets rw_flags differently. These typed accessors
    // push .rawValue extraction out of @inlinable bodies.

    extension Kernel.IO.Uring.Submission.Queue.Entry {
        /// Splice/tee operation flags.
        @usableFromInline
        internal var spliceFlags: Kernel.Pipe.Splice.Options {
            get { Kernel.Pipe.Splice.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        /// Rename operation flags.
        @usableFromInline
        internal var renameFlags: Kernel.File.Rename.Options {
            get { Kernel.File.Rename.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        /// Ring-to-ring message flags.
        @usableFromInline
        internal var messageRingFlags: Kernel.IO.Uring.Message.Options {
            get { Kernel.IO.Uring.Message.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        /// Futex operation flags.
        @usableFromInline
        internal var futexFlags: Kernel.Futex.Options {
            get { Kernel.Futex.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        /// Xattr create/replace disposition (write-only).
        ///
        /// Set-only because the raw bits encode multiple dispositions
        /// that cannot be losslessly round-tripped through the enum.
        @usableFromInline
        internal mutating func setXattrDisposition(
            _ disposition: Kernel.IO.Uring.File.Xattr.Disposition
        ) {
            cValue.rw_flags = disposition.rawBits
        }

        /// Waitid io_uring-level flags.
        @usableFromInline
        internal var waitidFlags: Kernel.IO.Uring.Wait.Options {
            get { Kernel.IO.Uring.Wait.Options(rawValue: cValue.rw_flags) }
            set { cValue.rw_flags = newValue.rawValue }
        }

        /// Poll event mask.
        @usableFromInline
        internal var pollEvents: Kernel.Event.Poll.Events {
            get { Kernel.Event.Poll.Events(rawValue: cValue.poll32_events) }
            set { cValue.poll32_events = newValue.rawValue }
        }

        /// Poll options (trigger mode + multishot).
        @usableFromInline
        internal var pollOptions: Kernel.IO.Uring.Poll.Options {
            get { Kernel.IO.Uring.Poll.Options(rawValue: cValue.len) }
            set { cValue.len = newValue.rawValue }
        }

        /// Waitid process kind.
        @usableFromInline
        internal var waitidKind: Kernel.Process.Wait.Kind {
            get { Kernel.Process.Wait.Kind(rawValue: Int32(bitPattern: cValue.len)) }
            set { cValue.len = UInt32(bitPattern: newValue.rawValue) }
        }

        /// Waitid POSIX wait options.
        @usableFromInline
        internal var waitidOptions: Kernel.Process.Wait.Options {
            get { Kernel.Process.Wait.Options(rawValue: Int32(bitPattern: cValue.file_index)) }
            set { cValue.file_index = UInt32(bitPattern: newValue.rawValue) }
        }

        /// Epoll control operation.
        @usableFromInline
        internal var epollOperation: Kernel.Event.Poll.Operation {
            get { Kernel.Event.Poll.Operation(rawValue: Int32(bitPattern: cValue.len)) }
            set { cValue.len = UInt32(bitPattern: newValue.rawValue) }
        }

        /// Epoll max events.
        @usableFromInline
        internal var epollMaxEvents: Int32 {
            get { Int32(bitPattern: cValue.len) }
            set { cValue.len = UInt32(bitPattern: newValue) }
        }

        /// Socket address family (stored in fd field for IORING_OP_SOCKET).
        @usableFromInline
        internal var socketDomain: Kernel.Socket.Address.Family {
            get { Kernel.Socket.Address.Family(rawValue: cValue.fd) }
            set { cValue.fd = newValue.rawValue }
        }

        /// Socket kind (stored in off field for IORING_OP_SOCKET).
        @usableFromInline
        internal var socketKind: Kernel.Socket.Kind {
            get { Kernel.Socket.Kind(rawValue: Int32(truncatingIfNeeded: cValue.off)) }
            set { cValue.off = UInt64(UInt32(bitPattern: newValue.rawValue)) }
        }

        /// Socket protocol (stored in len field for IORING_OP_SOCKET).
        @usableFromInline
        internal var socketProtocol: Kernel.Socket.`Protocol` {
            get { .init(rawValue: Int32(bitPattern: cValue.len)) }
            set { cValue.len = UInt32(bitPattern: newValue.rawValue) }
        }

        /// Socket creation flags (stored in rw_flags for IORING_OP_SOCKET).
        @usableFromInline
        internal var socketFlags: Kernel.Socket.Options {
            get { Kernel.Socket.Options(rawValue: Int32(bitPattern: cValue.rw_flags)) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.rawValue) }
        }

        /// Configure timeout from clock and options.
        @usableFromInline
        internal mutating func configureTimeout(
            clock: Kernel.IO.Uring.Clock,
            options: Kernel.IO.Uring.Timeout.Options = []
        ) {
            cValue.rw_flags = clock.timeoutBits | options.rawValue
        }

        /// Set the target process ID for waitid.
        @usableFromInline
        internal mutating func setWaitidProcess(_ id: Kernel.Process.ID) {
            cValue.fd = id.rawValue
        }

        /// Set the addr field from a pointer.
        @usableFromInline @unsafe
        internal mutating func setAddr(_ pointer: UnsafeRawPointer?) {
            cValue.addr = unsafe UInt64(UInt(bitPattern: pointer))
        }

        /// Set the addr field from operation data (cancel/timeout-remove/poll-remove target).
        @usableFromInline
        internal mutating func setAddr(_ data: Kernel.IO.Uring.Operation.Data) {
            cValue.addr = data.rawValue
        }

        /// Set the offset field from a pointer (openat2 how, statx buffer, etc.).
        @usableFromInline @unsafe
        internal mutating func setOffset(_ pointer: UnsafeRawPointer?) {
            cValue.off = unsafe UInt64(UInt(bitPattern: pointer))
        }

        /// Set the addr3 field from a pointer (xattr path).
        @usableFromInline @unsafe
        internal mutating func setAddr3(_ pointer: UnsafeRawPointer) {
            cValue.addr3 = unsafe UInt64(UInt(bitPattern: pointer))
        }

        /// Rename/link target directory fd (stored in len as UInt32(bitPattern:)).
        @usableFromInline
        internal var targetDirectoryFd: Int32 {
            get { Int32(bitPattern: cValue.len) }
            set { cValue.len = UInt32(bitPattern: newValue) }
        }

        /// Message ring value (stored in len).
        @usableFromInline
        internal var messageValue: UInt32 {
            get { cValue.len }
            set { cValue.len = newValue }
        }

        /// Message ring target ring fd (stored in fd).
        @usableFromInline
        internal var messageRingFd: Int32 {
            get { cValue.fd }
            set { cValue.fd = newValue }
        }

        /// Message ring target data (stored in off).
        @usableFromInline
        internal mutating func setMessageTarget(_ data: Kernel.IO.Uring.Operation.Data) {
            cValue.off = data.rawValue
        }

        /// Buffer provide/remove count (stored in fd).
        @usableFromInline
        internal var bufferCount: Int32 {
            get { cValue.fd }
            set { cValue.fd = newValue }
        }

        /// Buffer start ID (stored in off).
        @usableFromInline
        internal var bufferStartID: UInt16 {
            get { UInt16(truncatingIfNeeded: cValue.off) }
            set { cValue.off = UInt64(newValue) }
        }
    }

#endif
