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

            @unsafe @inlinable
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
            unsafe (pointer.pointee.cValue = io_uring_sqe())
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
        @unsafe @inlinable
        public func read(
            target: Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
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
        @unsafe @inlinable
        public func write(
            target: Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
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
            unsafe (pointer.pointee.cValue = io_uring_sqe())
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
            target: Kernel.IO.Uring.Target,
            datasync: Bool,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .sync.file)
            unsafe target.apply(to: pointer)
            if datasync {
                unsafe (pointer.pointee.opFlags = Int32(IORING_FSYNC_DATASYNC))
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
            target: Kernel.IO.Uring.Target,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .close)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an accept operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor, registered, or auto-allocate for accept-direct).
        ///   - addr: Optional pointer to sockaddr buffer.
        ///   - addrLen: Optional pointer to sockaddr length.
        ///   - flags: Accept flags.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func accept(
            target: Kernel.IO.Uring.Target,
            addr: UnsafeMutableRawPointer?,
            addrLen: UnsafeMutablePointer<UInt32>?,
            flags: Kernel.Socket.Flags,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.accept)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: addr)))
            unsafe (pointer.pointee.offset = Kernel.IO.Uring.Offset(UInt64(UInt(bitPattern: addrLen))))
            unsafe (pointer.pointee.opFlags = flags.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a connect operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - addr: Pointer to sockaddr.
        ///   - addrLen: Length of sockaddr.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func connect(
            target: Kernel.IO.Uring.Target,
            addr: UnsafeRawPointer,
            addrLen: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.connect)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: addr)))
            unsafe (pointer.pointee.offset = Kernel.IO.Uring.Offset(UInt64(addrLen)))
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
        @unsafe @inlinable
        public func send(
            target: Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.IO.Uring.Socket.Message.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.send)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.opFlags = flags.rawValue)
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
        @unsafe @inlinable
        public func recv(
            target: Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.IO.Uring.Socket.Message.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.receive)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.opFlags = flags.rawValue)
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
        @unsafe @inlinable
        public func read(
            target: Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<Kernel.IO.Uring.Vector>,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .read.vectored)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: vectors.baseAddress)))
            unsafe (pointer.pointee.cValue.len = UInt32(vectors.count))
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
        @unsafe @inlinable
        public func write(
            target: Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<Kernel.IO.Uring.Vector>,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .write.vectored)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: vectors.baseAddress)))
            unsafe (pointer.pointee.cValue.len = UInt32(vectors.count))
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
        @unsafe @inlinable
        public func read(
            target: Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            bufferIndex: Kernel.IO.Uring.Buffer.Index,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .read.fixed)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.cValue.buf_index = bufferIndex.rawValue)
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
        @unsafe @inlinable
        public func write(
            target: Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            bufferIndex: Kernel.IO.Uring.Buffer.Index,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .write.fixed)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.cValue.buf_index = bufferIndex.rawValue)
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
        @unsafe @inlinable
        public func read(
            target: Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<Kernel.IO.Uring.Vector>,
            offset: Kernel.IO.Uring.Offset,
            bufferIndex: Kernel.IO.Uring.Buffer.Index,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .read.vectoredFixed)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: vectors.baseAddress)))
            unsafe (pointer.pointee.cValue.len = UInt32(vectors.count))
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.cValue.buf_index = bufferIndex.rawValue)
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
        @unsafe @inlinable
        public func write(
            target: Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<Kernel.IO.Uring.Vector>,
            offset: Kernel.IO.Uring.Offset,
            bufferIndex: Kernel.IO.Uring.Buffer.Index,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .write.vectoredFixed)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: vectors.baseAddress)))
            unsafe (pointer.pointee.cValue.len = UInt32(vectors.count))
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.cValue.buf_index = bufferIndex.rawValue)
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
            target: Kernel.IO.Uring.Target,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            bufferGroup: Kernel.IO.Uring.Buffer.Group,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .read.multishot)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.cValue.buf_group = bufferGroup.rawValue)
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
            target: Kernel.IO.Uring.Target,
            source: borrowing Kernel.Descriptor,
            offsetIn: Kernel.IO.Uring.Offset,
            offsetOut: Kernel.IO.Uring.Offset,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.IO.Uring.Splice.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .pipe.splice)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.cValue.splice_fd_in = source._rawValue)
            unsafe (pointer.pointee.addr = offsetIn.rawValue)
            unsafe (pointer.pointee.offset = offsetOut)
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
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
            target: Kernel.IO.Uring.Target,
            source: borrowing Kernel.Descriptor,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.IO.Uring.Splice.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .pipe.tee)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.cValue.splice_fd_in = source._rawValue)
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
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
            target: Kernel.IO.Uring.Target,
            length: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
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
        /// - Parameters:
        ///   - target: Directory fd targeting (use `.descriptor` for dirfd, `.allocate` for direct open).
        ///   - path: Null-terminated path to open.
        ///   - flags: Open flags (O_RDONLY, O_WRONLY, etc.).
        ///   - mode: File mode for creation.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func openat(
            target: Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            flags: Kernel.IO.Uring.File.Open.Options,
            mode: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.openat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            unsafe (pointer.pointee.cValue.len = mode)
            unsafe (pointer.pointee.opFlags = flags.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an openat2 operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting (use `.descriptor` for dirfd, `.allocate` for direct open).
        ///   - path: Null-terminated path to open.
        ///   - how: Pointer to `open_how` struct specifying open parameters.
        ///   - size: Size of the `open_how` struct.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func openat2(
            target: Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            how: UnsafeRawPointer,
            size: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.openat2)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            unsafe (pointer.pointee.cValue.len = size)
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: how)))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a statx operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting.
        ///   - path: Null-terminated path to stat.
        ///   - flags: Statx flags (e.g., `AT_SYMLINK_NOFOLLOW`).
        ///   - mask: Statx mask (which fields to populate).
        ///   - buffer: Pointer to statx buffer for results.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func statx(
            target: Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            flags: Kernel.IO.Uring.File.At.Options,
            mask: UInt32,
            buffer: UnsafeMutableRawPointer,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.statx)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
            unsafe (pointer.pointee.cValue.len = mask)
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: buffer)))
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
        @unsafe @inlinable
        public func renameat(
            target: Kernel.IO.Uring.Target,
            oldPath: UnsafePointer<CChar>,
            newDirFd: Int32,
            newPath: UnsafePointer<CChar>,
            flags: Kernel.IO.Uring.File.Rename.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.renameat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: oldPath)))
            unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: newDirFd))
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: newPath)))
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an unlinkat operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting.
        ///   - path: Null-terminated path to unlink.
        ///   - flags: Unlink flags (e.g., `AT_REMOVEDIR`).
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func unlinkat(
            target: Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            flags: Kernel.IO.Uring.File.At.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.unlinkat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a mkdirat operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting.
        ///   - path: Null-terminated path for the new directory.
        ///   - mode: Directory permission mode.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func mkdirat(
            target: Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            mode: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.mkdirat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: path)))
            unsafe (pointer.pointee.cValue.len = mode)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a symlinkat operation.
        ///
        /// - Parameters:
        ///   - target: New directory fd targeting.
        ///   - linkTarget: Null-terminated symlink target path.
        ///   - linkPath: Null-terminated path for the new symlink.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func symlinkat(
            target: Kernel.IO.Uring.Target,
            linkTarget: UnsafePointer<CChar>,
            linkPath: UnsafePointer<CChar>,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.symlinkat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: linkTarget)))
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: linkPath)))
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
        @unsafe @inlinable
        public func linkat(
            target: Kernel.IO.Uring.Target,
            oldPath: UnsafePointer<CChar>,
            newDirFd: Int32,
            newPath: UnsafePointer<CChar>,
            flags: Kernel.IO.Uring.File.At.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.linkat)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: oldPath)))
            unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: newDirFd))
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: newPath)))
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
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
            target: Kernel.IO.Uring.Target,
            mode: Kernel.IO.Uring.File.Allocate.Mode,
            offset: Kernel.IO.Uring.Offset,
            length: UInt64,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.fallocate)
            unsafe target.apply(to: pointer)
            // WHY: fallocate stores the length in addr because the len field is only
            // 32-bit but fallocate's length parameter is 64-bit.
            unsafe (pointer.pointee.addr = length)
            unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: mode.rawBits))
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.data = data)
        }
    }

    // MARK: - Networking

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Configures this entry for a socket creation operation.
        ///
        /// - Parameters:
        ///   - domain: Protocol family (e.g., `AF_INET`, `AF_INET6`).
        ///   - type: Socket type (e.g., `SOCK_STREAM`, `SOCK_DGRAM`).
        ///   - protocol: Protocol number (typically 0).
        ///   - flags: Socket flags.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func socket(
            domain: Int32,
            type: Int32,
            protocol: Int32,
            flags: Kernel.Socket.Flags,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.create)
            unsafe (pointer.pointee.cValue.fd = domain)
            unsafe (pointer.pointee.cValue.rw_flags = UInt32(bitPattern: flags.rawValue))
            unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: `protocol`))
            unsafe (pointer.pointee.cValue.off = UInt64(UInt32(bitPattern: type)))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a socket bind operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - addr: Pointer to sockaddr.
        ///   - addrLen: Length of sockaddr.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func bind(
            target: Kernel.IO.Uring.Target,
            addr: UnsafeRawPointer,
            addrLen: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.bind)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: addr)))
            unsafe (pointer.pointee.cValue.off = UInt64(addrLen))
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
            target: Kernel.IO.Uring.Target,
            backlog: Int32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.listen)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.cValue.off = UInt64(UInt32(bitPattern: backlog)))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a sendmsg operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - message: Pointer to msghdr struct.
        ///   - flags: Message flags.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func send(
            target: Kernel.IO.Uring.Target,
            message: UnsafePointer<msghdr>,
            flags: Kernel.IO.Uring.Socket.Message.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.sendMessage)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: message)))
            unsafe (pointer.pointee.cValue.len = 1)
            unsafe (pointer.pointee.opFlags = flags.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a recvmsg operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - message: Pointer to msghdr struct for receiving.
        ///   - flags: Message flags.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func recv(
            target: Kernel.IO.Uring.Target,
            message: UnsafeMutablePointer<msghdr>,
            flags: Kernel.IO.Uring.Socket.Message.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.receiveMessage)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: message)))
            unsafe (pointer.pointee.cValue.len = 1)
            unsafe (pointer.pointee.opFlags = flags.rawValue)
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
        @unsafe @inlinable
        public func send(
            target: Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.IO.Uring.Socket.Message.Options,
            zeroCopyFlags: Kernel.IO.Uring.Priority,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .send.zero.copy)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.opFlags = flags.rawValue)
            unsafe (pointer.pointee.priority = zeroCopyFlags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a zero-copy sendmsg operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - message: Pointer to msghdr struct.
        ///   - flags: Message flags.
        ///   - zeroCopyFlags: Zero-copy flags (stored in ioprio).
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func send(
            target: Kernel.IO.Uring.Target,
            message: UnsafePointer<msghdr>,
            flags: Kernel.IO.Uring.Socket.Message.Options,
            zeroCopyFlags: Kernel.IO.Uring.Priority,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .send.zero.msg)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: message)))
            unsafe (pointer.pointee.cValue.len = 1)
            unsafe (pointer.pointee.opFlags = flags.rawValue)
            unsafe (pointer.pointee.priority = zeroCopyFlags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a socket shutdown operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - how: Shutdown mode (`SHUT_RD`, `SHUT_WR`, or `SHUT_RDWR`).
        ///   - data: Operation data to return with completion.
        @inlinable
        public func shutdown(
            target: Kernel.IO.Uring.Target,
            how: Int32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.shutdown)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: how))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an epoll_ctl operation.
        ///
        /// - Parameters:
        ///   - target: Epoll fd targeting.
        ///   - fd: Target file descriptor to add/modify/delete.
        ///   - op: Epoll operation (`EPOLL_CTL_ADD`, `EPOLL_CTL_MOD`, `EPOLL_CTL_DEL`).
        ///   - event: Pointer to epoll_event struct (may be nil for `EPOLL_CTL_DEL`).
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func epoll(
            target: Kernel.IO.Uring.Target,
            fd: Int32,
            op: Int32,
            event: UnsafeMutableRawPointer?,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .epoll.ctl)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: event)))
            unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: op))
            unsafe (pointer.pointee.cValue.off = UInt64(UInt32(bitPattern: fd)))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an epoll_wait operation.
        ///
        /// - Parameters:
        ///   - target: Epoll fd targeting.
        ///   - events: Pointer to epoll_event array for results.
        ///   - maxEvents: Maximum number of events to return.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func epoll(
            target: Kernel.IO.Uring.Target,
            events: UnsafeMutableRawPointer,
            maxEvents: Int32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .epoll.wait)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: events)))
            unsafe (pointer.pointee.cValue.len = UInt32(bitPattern: maxEvents))
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
        ///   - timespec: Pointer to kernel timespec specifying the duration.
        ///   - count: Number of completions to wait for (0 = time only).
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - multishot: If true, the timeout repeats automatically.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func timeout(
            after timespec: UnsafePointer<__kernel_timespec>,
            count: UInt32 = 0,
            clock: Kernel.IO.Uring.Clock = .monotonic,
            multishot: Bool = false,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .timeout.standard)
            unsafe (pointer.pointee.cValue.fd = -1)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: timespec)))
            unsafe (pointer.pointee.cValue.len = count)
            var rawFlags: UInt32 = clock.timeoutBits
            if multishot { rawFlags |= UInt32(IORING_TIMEOUT_MULTISHOT) }
            unsafe (pointer.pointee.cValue.rw_flags = rawFlags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an absolute timeout operation.
        ///
        /// Completes at the specified deadline or after `count` completions,
        /// whichever comes first.
        ///
        /// - Parameters:
        ///   - timespec: Pointer to kernel timespec specifying the deadline.
        ///   - count: Number of completions to wait for (0 = time only).
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - multishot: If true, the timeout repeats automatically.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func timeout(
            deadline timespec: UnsafePointer<__kernel_timespec>,
            count: UInt32 = 0,
            clock: Kernel.IO.Uring.Clock = .monotonic,
            multishot: Bool = false,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .timeout.standard)
            unsafe (pointer.pointee.cValue.fd = -1)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: timespec)))
            unsafe (pointer.pointee.cValue.len = count)
            var rawFlags: UInt32 = clock.timeoutBits | UInt32(IORING_TIMEOUT_ABS)
            if multishot { rawFlags |= UInt32(IORING_TIMEOUT_MULTISHOT) }
            unsafe (pointer.pointee.cValue.rw_flags = rawFlags)
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
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .timeout.remove)
            unsafe (pointer.pointee.cValue.fd = -1)
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
        ///   - timespec: Pointer to kernel timespec specifying the duration.
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func timeout(
            link timespec: UnsafePointer<__kernel_timespec>,
            clock: Kernel.IO.Uring.Clock = .monotonic,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .timeout.link)
            unsafe (pointer.pointee.cValue.fd = -1)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: timespec)))
            unsafe (pointer.pointee.cValue.len = 1)
            unsafe (pointer.pointee.cValue.rw_flags = clock.timeoutBits)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an absolute link timeout operation.
        ///
        /// Must be submitted immediately after the linked SQE it guards.
        /// If the linked operation doesn't complete by the deadline,
        /// it is cancelled.
        ///
        /// - Parameters:
        ///   - timespec: Pointer to kernel timespec specifying the deadline.
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func timeout(
            linkDeadline timespec: UnsafePointer<__kernel_timespec>,
            clock: Kernel.IO.Uring.Clock = .monotonic,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .timeout.link)
            unsafe (pointer.pointee.cValue.fd = -1)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: timespec)))
            unsafe (pointer.pointee.cValue.len = 1)
            unsafe (pointer.pointee.cValue.rw_flags = clock.timeoutBits | UInt32(IORING_TIMEOUT_ABS))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a poll add operation.
        ///
        /// Monitors a file descriptor for events.
        ///
        /// - Parameters:
        ///   - target: File targeting for the fd to poll.
        ///   - events: Poll event mask (e.g., `POLLIN`, `POLLOUT`).
        ///   - multishot: If true, produces CQEs on every event without resubmission.
        ///   - trigger: Trigger mode — edge (default) or level.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func poll(
            target: Kernel.IO.Uring.Target,
            events: UInt32,
            multishot: Bool = false,
            trigger: Kernel.IO.Uring.Poll.Trigger = .edge,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .poll.add)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.cValue.poll32_events = events)
            var rawFlags: UInt32 = trigger.pollBits
            if multishot { rawFlags |= UInt32(IORING_POLL_ADD_MULTI) }
            unsafe (pointer.pointee.cValue.len = rawFlags)
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
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .poll.remove)
            unsafe (pointer.pointee.cValue.fd = -1)
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
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .ring.msg)
            unsafe (pointer.pointee.cValue.fd = fd)
            unsafe (pointer.pointee.cValue.len = value)
            unsafe (pointer.pointee.cValue.off = targetData.rawValue)
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
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
        @unsafe @inlinable
        public func provide(
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            count: Int32,
            group: Kernel.IO.Uring.Buffer.Group,
            startId: UInt16,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .buffer.provide)
            unsafe (pointer.pointee.cValue.fd = count)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            // WHY: The off field stores the starting buffer ID, not a file offset.
            unsafe (pointer.pointee.cValue.off = UInt64(startId))
            unsafe (pointer.pointee.cValue.buf_group = group.rawValue)
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
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .buffer.remove)
            unsafe (pointer.pointee.cValue.fd = count)
            unsafe (pointer.pointee.cValue.buf_group = group.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a registered files update operation.
        ///
        /// - Parameters:
        ///   - fds: Pointer to array of file descriptors.
        ///   - count: Number of file descriptors.
        ///   - offset: Starting index in the registered file table.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func files(
            update fds: UnsafePointer<Int32>,
            count: UInt32,
            offset: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.filesUpdate)
            unsafe (pointer.pointee.cValue.fd = -1)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: fds)))
            unsafe (pointer.pointee.cValue.len = count)
            unsafe (pointer.pointee.cValue.off = UInt64(offset))
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
            target: Kernel.IO.Uring.Target,
            op: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .ring.cmd)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.cValue.cmd_op = op)
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
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .fixed.fdInstall)
            unsafe (pointer.pointee.cValue.fd = Int32(bitPattern: fd))
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a pipe creation operation.
        ///
        /// - Parameters:
        ///   - fds: Pointer to two-element Int32 array for read/write fds.
        ///   - flags: Pipe flags (e.g., `O_NONBLOCK`, `O_CLOEXEC`).
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func pipe(
            fds: UnsafeMutablePointer<Int32>,
            flags: Kernel.IO.Uring.Pipe.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .pipe.create)
            unsafe (pointer.pointee.cValue.fd = -1)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: fds)))
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a 128-byte no-op operation.
        ///
        /// - Parameter data: Operation data to return with completion.
        @inlinable
        public func nop128(data: Kernel.IO.Uring.Operation.Data) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .nop128)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a waitid operation.
        ///
        /// Waits for a child process state change (async `waitid(2)`).
        ///
        /// - Parameters:
        ///   - idtype: ID type (e.g., `P_PID`, `P_ALL`).
        ///   - id: Process/group ID to wait for.
        ///   - info: Pointer to siginfo_t for results.
        ///   - options: Wait options (e.g., `WEXITED`).
        ///   - flags: Waitid-specific flags.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func waitid(
            idtype: UInt32,
            id: Int32,
            info: UnsafeMutableRawPointer,
            options: UInt32,
            flags: Kernel.IO.Uring.Wait.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .wait.id)
            unsafe (pointer.pointee.cValue.fd = id)
            unsafe (pointer.pointee.cValue.len = idtype)
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: info)))
            unsafe (pointer.pointee.cValue.file_index = options)
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
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
        ///   - advice: Advisory hint (e.g., `POSIX_FADV_SEQUENTIAL`).
        ///   - data: Operation data to return with completion.
        @inlinable
        public func fadvise(
            target: Kernel.IO.Uring.Target,
            offset: Kernel.IO.Uring.Offset,
            length: Kernel.IO.Uring.Length,
            advice: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .file.fadvise)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.cValue.rw_flags = advice)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a memory advisory operation (madvise).
        ///
        /// - Parameters:
        ///   - addr: Start address of the memory region.
        ///   - length: Length of the memory region.
        ///   - advice: Advisory hint (e.g., `MADV_DONTNEED`).
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func madvise(
            addr: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            advice: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .memory.madvise)
            unsafe (pointer.pointee.cValue.fd = -1)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: addr)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.cValue.rw_flags = advice)
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
            target: Kernel.IO.Uring.Target,
            offset: Kernel.IO.Uring.Offset,
            length: Kernel.IO.Uring.Length,
            flags: Kernel.IO.Uring.Sync.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .sync.fileRange)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
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
        @unsafe @inlinable
        public func futex(
            wait futex: UnsafePointer<UInt32>,
            value: UInt64,
            mask: UInt64,
            flags: Kernel.IO.Uring.Futex.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .futex.wait)
            unsafe (pointer.pointee.cValue.fd = 0)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: futex)))
            unsafe (pointer.pointee.cValue.off = value)
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
            unsafe (pointer.pointee.cValue.addr3 = mask)
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
        @unsafe @inlinable
        public func futex(
            wake futex: UnsafePointer<UInt32>,
            value: UInt64,
            mask: UInt64,
            flags: Kernel.IO.Uring.Futex.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .futex.wake)
            unsafe (pointer.pointee.cValue.fd = 0)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: futex)))
            unsafe (pointer.pointee.cValue.off = value)
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
            unsafe (pointer.pointee.cValue.addr3 = mask)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a vectored futex wait operation (kernel 6.7+).
        ///
        /// Waits on multiple futexes simultaneously.
        ///
        /// - Parameters:
        ///   - waitv: Pointer to array of futex_waitv structs.
        ///   - count: Number of futex entries.
        ///   - flags: Futex flags.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func futex(
            waitv: UnsafePointer<futex_waitv>,
            count: UInt32,
            flags: Kernel.IO.Uring.Futex.Options,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .futex.waitv)
            unsafe (pointer.pointee.cValue.fd = 0)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: waitv)))
            unsafe (pointer.pointee.cValue.len = count)
            unsafe (pointer.pointee.cValue.rw_flags = flags.rawValue)
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
        @unsafe @inlinable
        public func fsetxattr(
            target: Kernel.IO.Uring.Target,
            name: UnsafePointer<CChar>,
            value: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            disposition: Kernel.IO.Uring.File.Xattr.Disposition = .createOrReplace,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .xattr.fset)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: name)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: value)))
            unsafe (pointer.pointee.cValue.rw_flags = disposition.rawBits)
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
        @unsafe @inlinable
        public func setxattr(
            name: UnsafePointer<CChar>,
            value: UnsafeRawPointer,
            path: UnsafePointer<CChar>,
            length: Kernel.IO.Uring.Length,
            disposition: Kernel.IO.Uring.File.Xattr.Disposition = .createOrReplace,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .xattr.set)
            unsafe (pointer.pointee.cValue.fd = 0)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: name)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: value)))
            unsafe (pointer.pointee.cValue.addr3 = UInt64(UInt(bitPattern: path)))
            unsafe (pointer.pointee.cValue.rw_flags = disposition.rawBits)
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
        @unsafe @inlinable
        public func fgetxattr(
            target: Kernel.IO.Uring.Target,
            name: UnsafePointer<CChar>,
            value: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .xattr.fget)
            unsafe target.apply(to: pointer)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: name)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: value)))
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
        @unsafe @inlinable
        public func getxattr(
            name: UnsafePointer<CChar>,
            value: UnsafeMutableRawPointer,
            path: UnsafePointer<CChar>,
            length: Kernel.IO.Uring.Length,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .xattr.get)
            unsafe (pointer.pointee.cValue.fd = 0)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: name)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.cValue.off = UInt64(UInt(bitPattern: value)))
            unsafe (pointer.pointee.cValue.addr3 = UInt64(UInt(bitPattern: path)))
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
