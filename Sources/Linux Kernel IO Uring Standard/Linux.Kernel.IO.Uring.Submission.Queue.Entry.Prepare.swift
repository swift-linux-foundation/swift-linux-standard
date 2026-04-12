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
    public import Linux_Kernel_System_Standard
    public import Linux_Kernel_Memory_Standard
    public import Kernel_Process_Primitives
    public import ISO_9945_Kernel_File

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.Submission.Queue.Entry {
        /// Pointer-based SQE preparation — mutates the entry in shared memory
        /// with zero copies.
        ///
        /// ~Copyable to prevent aliasing the pointer. Each `sqe.prepare` call
        /// returns a fresh value that is consumed by the prep method.
        ///
        /// ## SQE Initialization
        ///
        /// Every prep method zero-initializes the full 64-byte SQE before setting
        /// operation-specific fields. This is a conscious safety trade-off:
        /// liburing selectively zeroes only 7 union fields (saving ~40 bytes of
        /// memset per SQE), but that requires knowing exactly which fields each
        /// opcode does NOT set. Full-zero is safe by construction — no stale field
        /// from a previous operation leaks into the next. The ~16KB/batch cost
        /// (256 SQEs × 64 bytes) is negligible relative to the I/O latency.
        public struct Prepare: ~Copyable {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(_ pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }
        }
    }

    // MARK: - Operations

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for a no-op operation.
        ///
        /// - Parameter data: Operation data to return with completion.
        @inlinable
        public func nop(data: Kernel.IO.Uring.Operation.Data) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .nop)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a read operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor, registered index, or auto-allocate).
        ///   - buffer: Buffer pointer to read into.
        ///   - length: Number of bytes to read.
        ///   - offset: File offset (use `.current` for current position).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func read(
            target: borrowing Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .read.standard)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a write operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor, registered index, or auto-allocate).
        ///   - buffer: Buffer pointer containing data to write.
        ///   - length: Number of bytes to write.
        ///   - offset: File offset (use `.current` for current position).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func write(
            target: borrowing Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .write.standard)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a cancel operation.
        ///
        /// - Parameters:
        ///   - target: Operation data of the operation to cancel.
        ///   - data: Operation data to return with this cancel's completion.
        @inlinable
        public func cancel(
            target: Kernel.IO.Uring.Operation.Data,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .cancel.async)
            unsafe (pointer.pointee.addr = target.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an fsync operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - datasync: If true, only sync data (not metadata).
        ///   - data: Operation data to return with completion.
        @inlinable
        public func fsync(
            target: borrowing Kernel.IO.Uring.Target,
            datasync: Bool,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .sync.file)
            unsafe target.apply(to: pointer)
            if datasync {
                unsafe (pointer.pointee.opFlags = Kernel.IO.Uring.Submission.Queue.Entry.fsyncDatasync)
            }
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a close operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - data: Operation data to return with completion.
        @inlinable
        public func close(
            target: borrowing Kernel.IO.Uring.Target,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .close)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an accept operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor, registered, or auto-allocate for accept-direct).
        ///   - addr: Optional pointer to address storage buffer (kernel writes accepted address).
        ///   - length: Optional pointer to address length (in/out).
        ///   - flags: Accept flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func accept(
            target: borrowing Kernel.IO.Uring.Target,
            addr: UnsafeMutablePointer<Kernel.Socket.Address.Storage>?,
            length: UnsafeMutablePointer<UInt32>?,
            flags: Kernel.Socket.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.accept)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: addr)))
            unsafe (pointer.pointee.offset = Kernel.IO.Uring.Offset(UInt64(UInt(bitPattern: length))))
            unsafe (pointer.pointee.acceptFlags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a connect operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - address: Pointer to socket address storage.
        ///   - length: Length of socket address.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func connect(
            target: borrowing Kernel.IO.Uring.Target,
            address: UnsafePointer<Kernel.Socket.Address.Storage>,
            length: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.connect)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: address)))
            unsafe (pointer.pointee.offset = Kernel.IO.Uring.Offset(UInt64(length)))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a send operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - buffer: Buffer pointer containing data to send.
        ///   - length: Number of bytes to send.
        ///   - flags: Send flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func send(
            target: borrowing Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.Socket.Message.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.send)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.messageFlags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a recv operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - buffer: Buffer pointer to receive into.
        ///   - length: Maximum bytes to receive.
        ///   - flags: Recv flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func recv(
            target: borrowing Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.Socket.Message.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.receive)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.messageFlags = flags)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - File I/O (Vectored, Fixed, Multishot)

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for a vectored read operation (readv).
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor, registered index, or auto-allocate).
        ///   - vectors: Buffer pointer to Vector array.
        ///   - offset: File offset (use `.current` for current position).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func read(
            target: borrowing Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<Kernel.IO.Uring.Vector>,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .read.vectored)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: vectors.baseAddress)))
            unsafe (pointer.pointee._rawLength = UInt32(vectors.count))
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a vectored write operation (writev).
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor, registered index, or auto-allocate).
        ///   - vectors: Buffer pointer to Vector array.
        ///   - offset: File offset (use `.current` for current position).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func write(
            target: borrowing Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<Kernel.IO.Uring.Vector>,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .write.vectored)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: vectors.baseAddress)))
            unsafe (pointer.pointee._rawLength = UInt32(vectors.count))
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a fixed-buffer read operation.
        ///
        /// Reads into a pre-registered buffer, avoiding per-operation pinning overhead.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - buffer: Buffer pointer to read into (must be within a registered buffer).
        ///   - length: Number of bytes to read.
        ///   - offset: File offset (use `.current` for current position).
        ///   - bufferIndex: Index of the registered buffer.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func read(
            target: borrowing Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            bufferIndex: Kernel.IO.Uring.Buffer.Index,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .read.fixed)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.offset = offset)
            unsafe (self.buffer.index = bufferIndex)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a fixed-buffer write operation.
        ///
        /// Writes from a pre-registered buffer, avoiding per-operation pinning overhead.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - buffer: Buffer pointer containing data to write (must be within a registered buffer).
        ///   - length: Number of bytes to write.
        ///   - offset: File offset (use `.current` for current position).
        ///   - bufferIndex: Index of the registered buffer.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func write(
            target: borrowing Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            bufferIndex: Kernel.IO.Uring.Buffer.Index,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .write.fixed)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.offset = offset)
            unsafe (self.buffer.index = bufferIndex)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a vectored fixed-buffer read (readv into registered buffers).
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - vectors: Buffer pointer to Vector array (addresses must be within registered buffers).
        ///   - offset: File offset (use `.current` for current position).
        ///   - bufferIndex: Index of the registered buffer.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func read(
            target: borrowing Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<Kernel.IO.Uring.Vector>,
            offset: Kernel.IO.Uring.Offset,
            bufferIndex: Kernel.IO.Uring.Buffer.Index,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .read.vectoredFixed)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: vectors.baseAddress)))
            unsafe (pointer.pointee._rawLength = UInt32(vectors.count))
            unsafe (pointer.pointee.offset = offset)
            unsafe (self.buffer.index = bufferIndex)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a vectored fixed-buffer write (writev from registered buffers).
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - vectors: Buffer pointer to Vector array (addresses must be within registered buffers).
        ///   - offset: File offset (use `.current` for current position).
        ///   - bufferIndex: Index of the registered buffer.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func write(
            target: borrowing Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<Kernel.IO.Uring.Vector>,
            offset: Kernel.IO.Uring.Offset,
            bufferIndex: Kernel.IO.Uring.Buffer.Index,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .write.vectoredFixed)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: vectors.baseAddress)))
            unsafe (pointer.pointee._rawLength = UInt32(vectors.count))
            unsafe (pointer.pointee.offset = offset)
            unsafe (self.buffer.index = bufferIndex)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a multishot read operation.
        ///
        /// Produces multiple CQEs from a single SQE. Requires buffer selection —
        /// the kernel picks a buffer from the specified group for each completion.
        /// Check `IORING_CQE_F_MORE` on each CQE; resubmit when absent.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - length: Maximum bytes per read.
        ///   - offset: File offset (use `.current` for current position).
        ///   - bufferGroup: Buffer group for kernel-selected buffers.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func read(
            target: borrowing Kernel.IO.Uring.Target,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            bufferGroup: Kernel.IO.Uring.Buffer.Group,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .read.multishot)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.offset = offset)
            unsafe (self.buffer.group = bufferGroup)
            unsafe (pointer.pointee.flags.insert(.bufferSelect))
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - File I/O (Splice, Tee, Truncate)

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for a splice operation.
        ///
        /// Moves data between two file descriptors without copying through user space.
        ///
        /// - Parameters:
        ///   - target: Destination file targeting (fd_out).
        ///   - source: Source file descriptor (fd_in).
        ///   - offsetIn: Offset in the source file.
        ///   - offsetOut: Offset in the destination file.
        ///   - length: Number of bytes to transfer.
        ///   - flags: Splice flags (e.g., `SPLICE_F_MOVE`).
        ///   - data: Operation data to return with completion.
        @inlinable
        public func splice(
            target: borrowing Kernel.IO.Uring.Target,
            source: borrowing Kernel.Descriptor,
            offsetIn: Kernel.IO.Uring.Offset,
            offsetOut: Kernel.IO.Uring.Offset,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.Pipe.Splice.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .pipe.splice)
            unsafe target.apply(to: pointer)
            unsafe (splice.set(source: source))
            unsafe (pointer.pointee.addr = offsetIn.rawValue)
            unsafe (pointer.pointee.offset = offsetOut)
            unsafe (pointer.pointee.len = length)
            unsafe (splice.flags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a tee operation.
        ///
        /// Duplicates data between two pipe file descriptors without consuming
        /// the input.
        ///
        /// - Parameters:
        ///   - target: Destination pipe fd (fd_out).
        ///   - source: Source pipe descriptor (fd_in).
        ///   - length: Number of bytes to duplicate.
        ///   - flags: Splice flags.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func tee(
            target: borrowing Kernel.IO.Uring.Target,
            source: borrowing Kernel.Descriptor,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.Pipe.Splice.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .pipe.tee)
            unsafe target.apply(to: pointer)
            unsafe (splice.set(source: source))
            unsafe (pointer.pointee.len = length)
            unsafe (splice.flags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a file truncation operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - length: New file length in bytes.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func ftruncate(
            target: borrowing Kernel.IO.Uring.Target,
            length: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.ftruncate)
            unsafe target.apply(to: pointer)
            // WHY: ftruncate stores the new length in the off field as u64.
            // Using Offset type since it wraps the same SQE field, even though
            // semantically this is a length, not a file position.
            unsafe (pointer.pointee.offset = length)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - File System

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for an openat operation.
        ///
        /// The kernel's open flags are decomposed into two parameters:
        /// - `access`: The access mode (read-only, write-only, read-write)
        /// - `options`: Additional open options (create, truncate, append, etc.)
        ///
        /// These are combined into a single flags field in the SQE.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting (use `.descriptor` for dirfd, `.allocate` for direct open).
        ///   - path: Null-terminated path to open.
        ///   - access: File access mode (default: `.readOnly`).
        ///   - options: Additional open options (create, truncate, etc.).
        ///   - mode: File mode for creation.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func openat(
            target: borrowing Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            access: Kernel.File.Open.Access = .readOnly,
            options: Kernel.File.Open.Options = [],
            mode: Kernel.File.Permissions = .none,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.openat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            // Combine access mode and options into one flags field
            unsafe (pointer.pointee.opFlags = access.rawValue | options.rawValue)
            unsafe (pointer.pointee.filePermissions = mode)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an openat2 operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting (use `.descriptor` for dirfd, `.allocate` for direct open).
        ///   - path: Null-terminated path to open.
        ///   - how: Pointer to open parameters (must remain valid until completion).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func openat2(
            target: borrowing Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            how: UnsafePointer<Kernel.File.Open.How>,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.openat2)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            unsafe (pointer.pointee._rawLength = UInt32(MemoryLayout<Kernel.File.Open.How>.size))
            unsafe (pointer.pointee._rawOffset = UInt64(UInt(bitPattern: how)))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a statx operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting.
        ///   - path: Null-terminated path to stat.
        ///   - flags: Statx flags (e.g., `AT_SYMLINK_NOFOLLOW`).
        ///   - mask: Statx mask (which fields to populate).
        ///   - buffer: Pointer to statx buffer for results (kernel writes here).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func statx(
            target: borrowing Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            flags: Kernel.File.At.Options,
            mask: Kernel.File.Statx.Mask,
            buffer: UnsafeMutablePointer<Kernel.File.Statx>,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.statx)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            unsafe (statx.flags = flags)
            unsafe (statx.mask = mask)
            unsafe statx.set(buffer: buffer)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a renameat operation.
        ///
        /// - Parameters:
        ///   - target: Old directory fd targeting.
        ///   - oldPath: Null-terminated old path.
        ///   - newDirFd: New directory file descriptor.
        ///   - newPath: Null-terminated new path.
        ///   - flags: Rename flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func renameat(
            target: borrowing Kernel.IO.Uring.Target,
            oldPath: UnsafePointer<CChar>,
            newDirFd: Int32,
            newPath: UnsafePointer<CChar>,
            flags: Kernel.File.Rename.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.renameat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: oldPath)))
            unsafe rename.set(directory: newDirFd)
            unsafe rename.set(path: newPath)
            unsafe (rename.flags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an unlinkat operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting.
        ///   - path: Null-terminated path to unlink.
        ///   - flags: Unlink flags (e.g., `AT_REMOVEDIR`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func unlinkat(
            target: borrowing Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            flags: Kernel.File.At.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.unlinkat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            unsafe (pointer.pointee.atFlags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a mkdirat operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting.
        ///   - path: Null-terminated path for the new directory.
        ///   - mode: Directory permission mode.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func mkdirat(
            target: borrowing Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            mode: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.mkdirat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            unsafe (pointer.pointee._rawLength = mode)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a symlinkat operation.
        ///
        /// - Parameters:
        ///   - target: New directory fd targeting.
        ///   - linkTarget: Null-terminated symlink target path.
        ///   - linkPath: Null-terminated path for the new symlink.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func symlinkat(
            target: borrowing Kernel.IO.Uring.Target,
            linkTarget: UnsafePointer<CChar>,
            linkPath: UnsafePointer<CChar>,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.symlinkat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: linkTarget)))
            unsafe (pointer.pointee._rawOffset = UInt64(UInt(bitPattern: linkPath)))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a linkat operation.
        ///
        /// - Parameters:
        ///   - target: Old directory fd targeting.
        ///   - oldPath: Null-terminated old path.
        ///   - newDirFd: New directory file descriptor.
        ///   - newPath: Null-terminated new path.
        ///   - flags: Link flags (e.g., `AT_SYMLINK_FOLLOW`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func linkat(
            target: borrowing Kernel.IO.Uring.Target,
            oldPath: UnsafePointer<CChar>,
            newDirFd: Int32,
            newPath: UnsafePointer<CChar>,
            flags: Kernel.File.At.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.linkat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: oldPath)))
            unsafe link.set(directory: newDirFd)
            unsafe link.set(path: newPath)
            unsafe (link.flags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a fallocate operation.
        ///
        /// Preallocates or deallocates disk space for a file.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - mode: Allocation mode (e.g., `.allocate()`, `.punch`, `.zero(keepSize: true)`).
        ///   - offset: Starting offset in the file.
        ///   - length: Number of bytes to allocate.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func fallocate(
            target: borrowing Kernel.IO.Uring.Target,
            mode: Kernel.IO.Uring.File.Allocate.Mode,
            offset: Kernel.IO.Uring.Offset,
            length: UInt64,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.fallocate)
            unsafe target.apply(to: pointer)
            // WHY: fallocate stores the length in addr because the len field is only
            // 32-bit but fallocate's length parameter is 64-bit.
            unsafe (pointer.pointee.addr = length)
            unsafe (pointer.pointee._rawLength = UInt32(bitPattern: mode.rawBits))
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - Networking

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for a socket creation operation.
        ///
        /// - Parameters:
        ///   - domain: Address family (e.g., `.inet`, `.inet6`).
        ///   - kind: Socket kind (e.g., `.stream`, `.datagram`).
        ///   - protocol: Network protocol (default: `.auto`).
        ///   - flags: Socket flags.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func socket(
            domain: Kernel.Socket.Address.Family,
            kind: Kernel.Socket.Kind,
            protocol: Kernel.Socket.`Protocol` = .auto,
            flags: Kernel.Socket.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.create)
            unsafe (socket.domain = domain)
            unsafe (socket.flags = flags)
            unsafe (socket.protocol = `protocol`)
            unsafe (socket.kind = kind)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a socket bind operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - address: Pointer to socket address storage.
        ///   - length: Length of socket address.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func bind(
            target: borrowing Kernel.IO.Uring.Target,
            address: UnsafePointer<Kernel.Socket.Address.Storage>,
            length: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.bind)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: address)))
            unsafe (pointer.pointee.addressLength = length)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a socket listen operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - backlog: Maximum pending connection queue length.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func listen(
            target: borrowing Kernel.IO.Uring.Target,
            backlog: Int32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.listen)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.listenBacklog = backlog)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a sendmsg operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - message: Pointer to message header (must remain valid until completion).
        ///   - flags: Message flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func send(
            target: borrowing Kernel.IO.Uring.Target,
            message: UnsafePointer<Kernel.Socket.Message.Header>,
            flags: Kernel.Socket.Message.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.sendMessage)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: message)))
            unsafe (pointer.pointee._rawLength = 1)
            unsafe (pointer.pointee.messageFlags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a recvmsg operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - message: Pointer to message header (kernel writes results here).
        ///   - flags: Message flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func recv(
            target: borrowing Kernel.IO.Uring.Target,
            message: UnsafeMutablePointer<Kernel.Socket.Message.Header>,
            flags: Kernel.Socket.Message.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.receiveMessage)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: message)))
            unsafe (pointer.pointee._rawLength = 1)
            unsafe (pointer.pointee.messageFlags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a zero-copy send operation.
        ///
        /// Transmits directly from user memory to NIC without kernel copy.
        /// Produces two CQEs: one for acceptance, one with `IORING_CQE_F_NOTIF`
        /// when the buffer is safe to reuse.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - buffer: Buffer pointer containing data to send.
        ///   - length: Number of bytes to send.
        ///   - flags: Message flags.
        ///   - zeroCopyFlags: Zero-copy flags (stored in ioprio).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func send(
            target: borrowing Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.Socket.Message.Options,
            zeroCopyFlags: Kernel.IO.Uring.Priority,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .send.zero.copy)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.messageFlags = flags)
            unsafe (pointer.pointee.priority = zeroCopyFlags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a zero-copy sendmsg operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - message: Pointer to message header (must remain valid until notification CQE).
        ///   - flags: Message flags.
        ///   - zeroCopyFlags: Zero-copy flags (stored in ioprio).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func send(
            target: borrowing Kernel.IO.Uring.Target,
            message: UnsafePointer<Kernel.Socket.Message.Header>,
            flags: Kernel.Socket.Message.Options,
            zeroCopyFlags: Kernel.IO.Uring.Priority,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .send.zero.msg)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: message)))
            unsafe (pointer.pointee._rawLength = 1)
            unsafe (pointer.pointee.messageFlags = flags)
            unsafe (pointer.pointee.priority = zeroCopyFlags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a socket shutdown operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - how: Shutdown mode (`.read`, `.write`, or `.both`).
        ///   - data: Operation data to return with completion.
        @inlinable
        public func shutdown(
            target: borrowing Kernel.IO.Uring.Target,
            how: Kernel.Socket.Shutdown.Mode,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .socket.shutdown)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.shutdownMode = how)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an epoll_ctl operation.
        ///
        /// - Parameters:
        ///   - target: Epoll fd targeting.
        ///   - descriptor: Target file descriptor to add/modify/delete.
        ///   - operation: Epoll operation (add, modify, delete).
        ///   - event: Pointer to epoll event (may be nil for delete).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func epoll(
            target: borrowing Kernel.IO.Uring.Target,
            descriptor: borrowing Kernel.Descriptor,
            operation: Kernel.Event.Poll.Operation,
            event: UnsafeMutablePointer<Kernel.Event.Poll.Event>?,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .epoll.ctl)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: event)))
            unsafe (epoll.operation = operation)
            unsafe epoll.set(descriptor: descriptor)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an epoll_wait operation.
        ///
        /// - Parameters:
        ///   - target: Epoll fd targeting.
        ///   - events: Pointer to epoll event array for results.
        ///   - maxEvents: Maximum number of events to return.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func epoll(
            target: borrowing Kernel.IO.Uring.Target,
            events: UnsafeMutablePointer<Kernel.Event.Poll.Event>,
            maxEvents: Int32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .epoll.wait)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: events)))
            unsafe (epoll.maxEvents = maxEvents)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - Timeout and Poll

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for a relative timeout operation.
        ///
        /// Completes after the specified duration elapses or after `count`
        /// completions, whichever comes first.
        ///
        /// - Parameters:
        ///   - timespec: Pointer to timeout specification (must remain valid until completion).
        ///   - count: Number of completions to wait for (0 = time only).
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - multishot: If true, the timeout repeats automatically.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func timeout(
            after timespec: UnsafePointer<Kernel.IO.Uring.Timeout.Specification>,
            count: UInt32 = 0,
            clock: Kernel.IO.Uring.Clock = .monotonic,
            multishot: Bool = false,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .timeout.standard)
            unsafe Kernel.IO.Uring.Target.none.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: timespec)))
            unsafe (timeout.count = count)
            unsafe timeout.configure(clock: clock, options: multishot ? .multishot : [])
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an absolute timeout operation.
        ///
        /// Completes at the specified deadline or after `count` completions,
        /// whichever comes first.
        ///
        /// - Parameters:
        ///   - timespec: Pointer to timeout specification (must remain valid until completion).
        ///   - count: Number of completions to wait for (0 = time only).
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - multishot: If true, the timeout repeats automatically.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func timeout(
            deadline timespec: UnsafePointer<Kernel.IO.Uring.Timeout.Specification>,
            count: UInt32 = 0,
            clock: Kernel.IO.Uring.Clock = .monotonic,
            multishot: Bool = false,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .timeout.standard)
            unsafe Kernel.IO.Uring.Target.none.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: timespec)))
            unsafe (timeout.count = count)
            unsafe timeout.configure(clock: clock, options: multishot ? [.absolute, .multishot] : .absolute)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a timeout removal operation.
        ///
        /// - Parameters:
        ///   - target: Operation data of the timeout to remove.
        ///   - data: Operation data to return with this operation's completion.
        @inlinable
        public func timeout(
            remove target: Kernel.IO.Uring.Operation.Data,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .timeout.remove)
            unsafe Kernel.IO.Uring.Target.none.apply(to: pointer)
            unsafe (pointer.pointee.addr = target.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a relative link timeout operation.
        ///
        /// Must be submitted immediately after the linked SQE it guards.
        /// If the linked operation doesn't complete within the duration,
        /// it is cancelled.
        ///
        /// - Parameters:
        ///   - timespec: Pointer to timeout specification (must remain valid until completion).
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func timeout(
            link timespec: UnsafePointer<Kernel.IO.Uring.Timeout.Specification>,
            clock: Kernel.IO.Uring.Clock = .monotonic,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .timeout.link)
            unsafe Kernel.IO.Uring.Target.none.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: timespec)))
            unsafe (timeout.count = 1)
            unsafe timeout.configure(clock: clock)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an absolute link timeout operation.
        ///
        /// Must be submitted immediately after the linked SQE it guards.
        /// If the linked operation doesn't complete by the deadline,
        /// it is cancelled.
        ///
        /// - Parameters:
        ///   - timespec: Pointer to timeout specification (must remain valid until completion).
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func timeout(
            linkDeadline timespec: UnsafePointer<Kernel.IO.Uring.Timeout.Specification>,
            clock: Kernel.IO.Uring.Clock = .monotonic,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .timeout.link)
            unsafe Kernel.IO.Uring.Target.none.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: timespec)))
            unsafe (timeout.count = 1)
            unsafe timeout.configure(clock: clock, options: .absolute)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a poll add operation.
        ///
        /// Monitors a file descriptor for events.
        ///
        /// - Parameters:
        ///   - target: File targeting for the fd to poll.
        ///   - events: Poll event mask (e.g., `.in`, `.out`).
        ///   - multishot: If true, produces CQEs on every event without resubmission.
        ///   - trigger: Trigger mode — edge (default) or level.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func poll(
            target: borrowing Kernel.IO.Uring.Target,
            events: Kernel.Event.Poll.Events,
            multishot: Bool = false,
            trigger: Kernel.IO.Uring.Poll.Trigger = .edge,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .poll.add)
            unsafe target.apply(to: pointer)
            unsafe (poll.events = events)
            var options = trigger.option
            if multishot { options.insert(.multishot) }
            unsafe (poll.options = options)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a poll removal operation.
        ///
        /// - Parameters:
        ///   - target: Operation data of the poll operation to remove.
        ///   - data: Operation data to return with this operation's completion.
        @inlinable
        public func poll(
            remove target: Kernel.IO.Uring.Operation.Data,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .poll.remove)
            unsafe (Kernel.IO.Uring.Target.none.apply(to: pointer))
            unsafe (pointer.pointee.addr = target.rawValue)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - Control and Utility

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for a ring-to-ring message operation.
        ///
        /// Injects a CQE with the specified value and user_data into the target ring.
        ///
        /// - Parameters:
        ///   - fd: Target ring file descriptor.
        ///   - value: Value to pass as CQE `res`.
        ///   - targetData: User data for the injected CQE.
        ///   - flags: Message ring flags.
        ///   - data: Operation data for this operation's own completion.
        @inlinable
        public func message(
            ring fd: Int32,
            value: UInt32,
            targetData: Kernel.IO.Uring.Operation.Data,
            flags: Kernel.IO.Uring.Message.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .ring.msg)
            unsafe (message.ring = fd)
            unsafe (message.value = value)
            unsafe (message.target = targetData.rawValue)
            unsafe (message.flags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a provide buffers operation (legacy).
        ///
        /// Provides a set of buffers to the kernel for automatic buffer selection.
        /// Prefer ring-mapped buffers (`IORING_REGISTER_PBUF_RING`) for new code.
        ///
        /// - Parameters:
        ///   - buffer: Pointer to the buffer memory.
        ///   - length: Size of each individual buffer.
        ///   - count: Number of buffers to provide.
        ///   - group: Buffer group ID.
        ///   - startId: Starting buffer ID.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func provide(
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            count: Int32,
            group: Kernel.IO.Uring.Buffer.Group,
            startId: UInt16,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .buffer.provide)
            unsafe (self.buffer.count = count)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (self.buffer.startID = startId)
            unsafe (self.buffer.group = group)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a remove buffers operation.
        ///
        /// - Parameters:
        ///   - count: Number of buffers to remove.
        ///   - group: Buffer group ID.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func remove(
            bufferCount count: Int32,
            group: Kernel.IO.Uring.Buffer.Group,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .buffer.remove)
            unsafe (self.buffer.count = count)
            unsafe (self.buffer.group = group)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a registered files update operation.
        ///
        /// - Parameters:
        ///   - fds: Pointer to array of file descriptors.
        ///   - count: Number of file descriptors.
        ///   - offset: Starting index in the registered file table.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func files(
            update fds: UnsafePointer<Int32>,
            count: UInt32,
            offset: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.filesUpdate)
            unsafe (Kernel.IO.Uring.Target.none.apply(to: pointer))
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: fds)))
            unsafe (pointer.pointee._rawLength = count)
            unsafe (pointer.pointee._rawOffset = UInt64(offset))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a uring passthrough command.
        ///
        /// Passes a device-specific command through the io_uring framework
        /// (e.g., NVMe passthrough).
        ///
        /// - Parameters:
        ///   - target: Device file targeting.
        ///   - op: Command opcode.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func command(
            target: borrowing Kernel.IO.Uring.Target,
            op: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .ring.cmd)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.commandOpcode = op)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a fixed fd install operation.
        ///
        /// Promotes a direct (registered) file descriptor into the process
        /// file descriptor table, making it accessible to legacy syscalls.
        ///
        /// - Parameters:
        ///   - fd: Fixed file index to install.
        ///   - flags: Install flags.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func install(
            fd: UInt32,
            flags: Kernel.IO.Uring.Fixed.Install.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .fixed.fdInstall)
            unsafe (pointer.pointee._fd = Int32(bitPattern: fd))
            unsafe (pointer.pointee.installFlags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a pipe creation operation.
        ///
        /// - Parameters:
        ///   - fds: Pointer to two-element Int32 array for read/write fds.
        ///   - flags: Pipe flags (e.g., `O_NONBLOCK`, `O_CLOEXEC`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func pipe(
            fds: UnsafeMutablePointer<Int32>,
            flags: Kernel.Pipe.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .pipe.create)
            unsafe (Kernel.IO.Uring.Target.none.apply(to: pointer))
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: fds)))
            unsafe (pointer.pointee.pipeCreateFlags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a 128-byte no-op operation.
        ///
        /// - Parameter data: Operation data to return with completion.
        @inlinable
        public func nop128(data: Kernel.IO.Uring.Operation.Data) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .nop128)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a waitid operation.
        ///
        /// Waits for a child process state change (async `waitid(2)`).
        ///
        /// - Parameters:
        ///   - kind: Type of process identifier to wait for.
        ///   - id: Process or group ID.
        ///   - info: Pointer to signal information buffer (kernel writes results here).
        ///   - options: Wait options specifying which state changes to report.
        ///   - flags: Waitid-specific io_uring flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func waitid(
            kind: Kernel.Process.Wait.Kind,
            id: Kernel.Process.ID,
            info: UnsafeMutablePointer<Kernel.Signal.Information>,
            options: Kernel.Process.Wait.Options,
            flags: Kernel.IO.Uring.Wait.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .wait.id)
            unsafe waitid.set(process: id)
            unsafe (waitid.kind = kind)
            unsafe waitid.set(info: info)
            unsafe (waitid.waitOptions = options)
            unsafe (waitid.uringFlags = flags)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - File and Memory Advisory

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for a file advisory operation (fadvise).
        ///
        /// - Parameters:
        ///   - target: File targeting.
        ///   - offset: Starting offset.
        ///   - length: Length of the advisory region.
        ///   - advice: File access pattern advisory hint.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func fadvise(
            target: borrowing Kernel.IO.Uring.Target,
            offset: Kernel.IO.Uring.Offset,
            length: Kernel.IO.Uring.Length,
            advice: Kernel.File.Advice,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .file.fadvise)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.fileAdvice = advice)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a memory advisory operation (madvise).
        ///
        /// - Parameters:
        ///   - addr: Start address of the memory region.
        ///   - length: Length of the memory region.
        ///   - advice: Memory access pattern advisory hint.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func madvise(
            addr: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            advice: Kernel.Memory.Advice,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .memory.madvise)
            unsafe (Kernel.IO.Uring.Target.none.apply(to: pointer))
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: addr)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.memoryAdvice = advice)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a sync file range operation.
        ///
        /// - Parameters:
        ///   - target: File targeting.
        ///   - offset: Starting offset in the file.
        ///   - length: Number of bytes to sync.
        ///   - flags: Sync range flags.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func sync(
            target: borrowing Kernel.IO.Uring.Target,
            offset: Kernel.IO.Uring.Offset,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.File.Sync.Range.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .sync.fileRange)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.syncRangeFlags = flags)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - Futex

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for a futex wait operation (kernel 6.7+).
        ///
        /// - Parameters:
        ///   - futex: Pointer to the futex word.
        ///   - value: Expected value to compare against.
        ///   - mask: Bit mask for comparison.
        ///   - flags: Futex flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func futex(
            wait futex: UnsafePointer<UInt32>,
            value: UInt64,
            mask: UInt64,
            flags: Kernel.Futex.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .futex.wait)

            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: futex)))
            unsafe (pointer.pointee.offset = Kernel.IO.Uring.Offset(value))
            unsafe (self.futex.flags = flags)
            unsafe (self.futex.mask = mask)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a futex wake operation (kernel 6.7+).
        ///
        /// - Parameters:
        ///   - futex: Pointer to the futex word.
        ///   - value: Number of waiters to wake.
        ///   - mask: Bit mask for matching waiters.
        ///   - flags: Futex flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func futex(
            wake futex: UnsafePointer<UInt32>,
            value: UInt64,
            mask: UInt64,
            flags: Kernel.Futex.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .futex.wake)

            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: futex)))
            unsafe (pointer.pointee.offset = Kernel.IO.Uring.Offset(value))
            unsafe (self.futex.flags = flags)
            unsafe (self.futex.mask = mask)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a vectored futex wait operation (kernel 6.7+).
        ///
        /// Waits on multiple futexes simultaneously.
        ///
        /// - Parameters:
        ///   - entries: Pointer to contiguous array of wait entries (must remain valid until completion).
        ///   - count: Number of futex entries.
        ///   - flags: Futex flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func futex(
            wait entries: UnsafePointer<Kernel.Futex.Wait.Entry>,
            count: UInt32,
            flags: Kernel.Futex.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .futex.waitv)

            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: entries)))
            unsafe (self.futex.count = count)
            unsafe (self.futex.flags = flags)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - Extended Attributes

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for an fsetxattr operation.
        ///
        /// Sets an extended attribute on a file descriptor.
        ///
        /// - Parameters:
        ///   - target: File targeting.
        ///   - name: Null-terminated attribute name.
        ///   - value: Attribute value pointer.
        ///   - length: Length of the attribute value.
        ///   - disposition: How to handle existing/absent attributes (default: `.createOrReplace`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func fsetxattr(
            target: borrowing Kernel.IO.Uring.Target,
            name: UnsafePointer<CChar>,
            value: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            disposition: Kernel.IO.Uring.File.Xattr.Disposition = .createOrReplace,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .xattr.fset)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: name)))
            unsafe (pointer.pointee.len = length)
            unsafe xattr.set(value: value)
            unsafe (xattr.disposition = disposition)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a setxattr operation.
        ///
        /// Sets an extended attribute by path.
        ///
        /// - Parameters:
        ///   - name: Null-terminated attribute name.
        ///   - value: Attribute value pointer.
        ///   - path: Null-terminated file path.
        ///   - length: Length of the attribute value.
        ///   - disposition: How to handle existing/absent attributes (default: `.createOrReplace`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func setxattr(
            name: UnsafePointer<CChar>,
            value: UnsafeRawPointer,
            path: UnsafePointer<CChar>,
            length: Kernel.IO.Uring.Length,
            disposition: Kernel.IO.Uring.File.Xattr.Disposition = .createOrReplace,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .xattr.set)

            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: name)))
            unsafe (pointer.pointee.len = length)
            unsafe xattr.set(value: value)
            unsafe xattr.set(path: path)
            unsafe (xattr.disposition = disposition)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an fgetxattr operation.
        ///
        /// Gets an extended attribute from a file descriptor.
        ///
        /// - Parameters:
        ///   - target: File targeting.
        ///   - name: Null-terminated attribute name.
        ///   - value: Buffer for the attribute value.
        ///   - length: Length of the value buffer.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func fgetxattr(
            target: borrowing Kernel.IO.Uring.Target,
            name: UnsafePointer<CChar>,
            value: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .xattr.fget)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: name)))
            unsafe (pointer.pointee.len = length)
            unsafe xattr.set(value: value)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a getxattr operation.
        ///
        /// Gets an extended attribute by path.
        ///
        /// - Parameters:
        ///   - name: Null-terminated attribute name.
        ///   - value: Buffer for the attribute value.
        ///   - path: Null-terminated file path.
        ///   - length: Length of the value buffer.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public func getxattr(
            name: UnsafePointer<CChar>,
            value: UnsafeMutableRawPointer,
            path: UnsafePointer<CChar>,
            length: Kernel.IO.Uring.Length,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee = .init())
            unsafe (pointer.pointee.opcode = .xattr.get)

            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: name)))
            unsafe (pointer.pointee.len = length)
            unsafe xattr.set(value: value)
            unsafe xattr.set(path: path)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - Accessor

    extension UnsafeMutablePointer
    where Pointee == Kernel.IO.Uring.Submission.Queue.Entry {
        /// Prepare an SQE operation through this pointer — zero copies.
        ///
        /// ```swift
        /// let sqe = ring.nextEntry()!
        /// unsafe sqe.prepare.read(target: .descriptor(fd), buffer: buf, length: len, offset: .zero, data: id)
        /// ring.advance()
        /// ```
        @unsafe
        public var prepare: Pointee.Prepare {
            unsafe Pointee.Prepare(self)
        }
    }

#endif
