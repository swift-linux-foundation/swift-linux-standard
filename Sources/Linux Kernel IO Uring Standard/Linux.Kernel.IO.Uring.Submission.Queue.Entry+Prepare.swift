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

    public import ISO_9945_Kernel_Process
    public import ISO_9945_Kernel_Socket_Address
    public import ISO_9945_Kernel_Socket
    public import Error_Primitives
    public import Memory_Primitives
    public import Memory_Map_Primitives
    public import Linux_Kernel_File_Standard
    public import Linux_Kernel_Pipe_Standard
    public import Linux_Kernel_Event_Standard
    public import Linux_Kernel_Futex_Standard
    public import Linux_Kernel_Socket_Standard
    public import Linux_Kernel_System_Standard
    public import Linux_Kernel_Memory_Standard
    public import ISO_9945_Kernel_File
    public import ISO_9945_Kernel_Signal
    public import ISO_9945_Core

    // MARK: - Operations

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
        /// Configures this entry for a no-op operation.
        ///
        /// - Parameter data: Operation data to return with completion.
        @inlinable
        public mutating func nop(data: ISO_9945.Kernel.IO.Uring.Operation.Data) {
            self = .init()
            self.opcode = .nop
            self.data = data
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
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.standard
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.offset = offset
            self.data = data
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
        public mutating func write(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .write.standard
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.offset = offset
            self.data = data
        }

        /// Configures this entry for a cancel operation.
        ///
        /// - Parameters:
        ///   - target: Operation data of the operation to cancel.
        ///   - data: Operation data to return with this cancel's completion.
        @inlinable
        public mutating func cancel(
            target: ISO_9945.Kernel.IO.Uring.Operation.Data,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .cancel.async
            self.setAddr(target)
            self.data = data
        }

        /// Configures this entry for an fsync operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - datasync: If true, only sync data (not metadata).
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func fsync(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            datasync: Bool,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .sync.file.standard
            target.apply(to: &self)
            if datasync {
                self.opFlags = Self.fsyncDatasync
            }
            self.data = data
        }

        /// Configures this entry for a close operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func close(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .close
            target.apply(to: &self)
            self.data = data
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
        public mutating func accept(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            addr: UnsafeMutablePointer<ISO_9945.Kernel.Socket.Address.Storage>?,
            length: UnsafeMutablePointer<UInt32>?,
            flags: ISO_9945.Kernel.Socket.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.accept
            target.apply(to: &self)
            unsafe self.setAddr(addr)
            unsafe self.setOffset(length)
            self.acceptFlags = flags
            self.data = data
        }

        /// Configures this entry for a connect operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - address: Pointer to socket address storage.
        ///   - length: Length of socket address.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func connect(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            address: UnsafePointer<ISO_9945.Kernel.Socket.Address.Storage>,
            length: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.connect
            target.apply(to: &self)
            unsafe self.setAddr(address)
            self.offset = ISO_9945.Kernel.IO.Uring.Offset(UInt64(length))
            self.data = data
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
        public mutating func send(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.send
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.messageFlags = flags
            self.data = data
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
        public mutating func recv(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.receive
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.messageFlags = flags
            self.data = data
        }
    }

    // MARK: - File I/O (Vectored, Fixed, Multishot)

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
        /// Configures this entry for a vectored read operation (readv).
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor, registered index, or auto-allocate).
        ///   - vectors: Buffer pointer to Vector array.
        ///   - offset: File offset (use `.current` for current position).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<ISO_9945.Kernel.IO.Vector.Segment>,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.vectored.standard
            target.apply(to: &self)
            unsafe self.setAddr(vectors.baseAddress)
            self._rawLength = UInt32(vectors.count)
            self.offset = offset
            self.data = data
        }

        /// Configures this entry for a vectored write operation (writev).
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor, registered index, or auto-allocate).
        ///   - vectors: Buffer pointer to Vector array.
        ///   - offset: File offset (use `.current` for current position).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func write(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<ISO_9945.Kernel.IO.Vector.Segment>,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .write.vectored.standard
            target.apply(to: &self)
            unsafe self.setAddr(vectors.baseAddress)
            self._rawLength = UInt32(vectors.count)
            self.offset = offset
            self.data = data
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
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferIndex: ISO_9945.Kernel.IO.Uring.Buffer.Index,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.fixed
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.offset = offset
            self._bufferIndex = bufferIndex
            self.data = data
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
        public mutating func write(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferIndex: ISO_9945.Kernel.IO.Uring.Buffer.Index,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .write.fixed
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.offset = offset
            self._bufferIndex = bufferIndex
            self.data = data
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
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<ISO_9945.Kernel.IO.Vector.Segment>,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferIndex: ISO_9945.Kernel.IO.Uring.Buffer.Index,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.vectored.fixed
            target.apply(to: &self)
            unsafe self.setAddr(vectors.baseAddress)
            self._rawLength = UInt32(vectors.count)
            self.offset = offset
            self._bufferIndex = bufferIndex
            self.data = data
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
        public mutating func write(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            vectors: UnsafeBufferPointer<ISO_9945.Kernel.IO.Vector.Segment>,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferIndex: ISO_9945.Kernel.IO.Uring.Buffer.Index,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .write.vectored.fixed
            target.apply(to: &self)
            unsafe self.setAddr(vectors.baseAddress)
            self._rawLength = UInt32(vectors.count)
            self.offset = offset
            self._bufferIndex = bufferIndex
            self.data = data
        }

        /// Configures this entry for a multishot read operation.
        ///
        /// Produces multiple CQEs from a single SQE. Requires buffer selection —
        /// the kernel picks a buffer from the specified group for each completion.
        ///
        /// Check `IORING_CQE_F_MORE` on each CQE; resubmit when absent.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - length: Maximum bytes per read.
        ///   - offset: File offset (use `.current` for current position).
        ///   - bufferGroup: Buffer group for kernel-selected buffers.
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func read(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            length: ISO_9945.Kernel.IO.Uring.Length,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            bufferGroup: ISO_9945.Kernel.IO.Uring.Buffer.Group,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .read.multishot
            target.apply(to: &self)
            self.len = length
            self.offset = offset
            self._bufferGroup = bufferGroup
            self.flags.insert(.bufferSelect)
            self.data = data
        }
    }

    // MARK: - File I/O (Splice, Tee, Truncate)

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
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
        ///   - flags: Splice flags (for example, `SPLICE_F_MOVE`).
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func splice(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            source: borrowing ISO_9945.Kernel.Descriptor,
            offsetIn: ISO_9945.Kernel.IO.Uring.Offset,
            offsetOut: ISO_9945.Kernel.IO.Uring.Offset,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Pipe.Splice.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .pipe.splice
            target.apply(to: &self)
            self.setSpliceSource(source)
            self.addr = offsetIn.underlying
            self.offset = offsetOut
            self.len = length
            self.spliceFlags = flags
            self.data = data
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
        public mutating func tee(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            source: borrowing ISO_9945.Kernel.Descriptor,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Pipe.Splice.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .pipe.tee
            target.apply(to: &self)
            self.setSpliceSource(source)
            self.len = length
            self.spliceFlags = flags
            self.data = data
        }

        /// Configures this entry for a file truncation operation.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - length: New file length in bytes.
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func ftruncate(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            length: ISO_9945.Kernel.IO.Uring.Offset,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.ftruncate
            target.apply(to: &self)
            // WHY: ftruncate stores the new length in the off field as u64.
            // Using Offset type since it wraps the same SQE field, even though
            // semantically this is a length, not a file position.
            self.offset = length
            self.data = data
        }
    }

    // MARK: - File System

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
        /// Configures this entry for an openat operation.
        ///
        /// The kernel's open flags are decomposed into two parameters:
        /// - `access`: The access mode (read-only, write-only, read-write)
        /// - `options`: Additional open options (create, truncate, append, and similar)
        ///
        /// These are combined into a single flags field in the SQE.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting (use `.descriptor` for dirfd, `.allocate` for direct open).
        ///   - path: Null-terminated path to open.
        ///   - access: File access mode (default: `.readOnly`).
        ///   - options: Additional open options (create, truncate, and similar).
        ///   - mode: File mode for creation.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func openat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            access: ISO_9945.Kernel.File.Open.Access = .readOnly,
            options: ISO_9945.Kernel.File.Open.Options = [],
            mode: ISO_9945.Kernel.File.Permissions = .none,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.openat
            target.apply(to: &self)
            unsafe self.setAddr(path)
            // Combine access mode and options into one flags field
            self.opFlags = access.rawValue | options.rawValue
            self.filePermissions = mode
            self.data = data
        }

        /// Configures this entry for an openat2 operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting (use `.descriptor` for dirfd, `.allocate` for direct open).
        ///   - path: Null-terminated path to open.
        ///   - how: Pointer to open parameters (must remain valid until completion).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func openat2(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            how: UnsafePointer<ISO_9945.Kernel.File.Open.How>,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.openat2
            target.apply(to: &self)
            unsafe self.setAddr(path)
            self._rawLength = UInt32(MemoryLayout<ISO_9945.Kernel.File.Open.How>.size)
            unsafe self.setOffset(how)
            self.data = data
        }

        /// Configures this entry for a statx operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting.
        ///   - path: Null-terminated path to stat.
        ///   - flags: Statx flags (for example, `AT_SYMLINK_NOFOLLOW`).
        ///   - mask: Statx mask (which fields to populate).
        ///   - buffer: Pointer to statx buffer for results (kernel writes here).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func statx(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            flags: ISO_9945.Kernel.File.At.Options,
            mask: ISO_9945.Kernel.File.Statx.Mask,
            buffer: UnsafeMutablePointer<ISO_9945.Kernel.File.Statx>,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.statx
            target.apply(to: &self)
            unsafe self.setAddr(path)
            self.atFlags = flags
            self._rawLength = mask.rawValue
            unsafe self.setOffset(buffer)
            self.data = data
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
        public mutating func renameat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            oldPath: UnsafePointer<CChar>,
            newDirFd: Int32,
            newPath: UnsafePointer<CChar>,
            flags: ISO_9945.Kernel.File.Rename.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.renameat
            target.apply(to: &self)
            unsafe self.setAddr(oldPath)
            self._rawLength = UInt32(bitPattern: newDirFd)
            unsafe self.setOffset(newPath)
            self.renameFlags = flags
            self.data = data
        }

        /// Configures this entry for an unlinkat operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting.
        ///   - path: Null-terminated path to unlink.
        ///   - flags: Unlink flags (for example, `AT_REMOVEDIR`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func unlinkat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            flags: ISO_9945.Kernel.File.At.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.unlinkat
            target.apply(to: &self)
            unsafe self.setAddr(path)
            self.atFlags = flags
            self.data = data
        }

        /// Configures this entry for a mkdirat operation.
        ///
        /// - Parameters:
        ///   - target: Directory fd targeting.
        ///   - path: Null-terminated path for the new directory.
        ///   - mode: Directory permission mode.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func mkdirat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            path: UnsafePointer<CChar>,
            mode: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.mkdirat
            target.apply(to: &self)
            unsafe self.setAddr(path)
            self._rawLength = mode
            self.data = data
        }

        /// Configures this entry for a symlinkat operation.
        ///
        /// - Parameters:
        ///   - target: New directory fd targeting.
        ///   - linkTarget: Null-terminated symlink target path.
        ///   - linkPath: Null-terminated path for the new symlink.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func symlinkat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            linkTarget: UnsafePointer<CChar>,
            linkPath: UnsafePointer<CChar>,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.symlinkat
            target.apply(to: &self)
            unsafe self.setAddr(linkTarget)
            unsafe self.setOffset(linkPath)
            self.data = data
        }

        /// Configures this entry for a linkat operation.
        ///
        /// - Parameters:
        ///   - target: Old directory fd targeting.
        ///   - oldPath: Null-terminated old path.
        ///   - newDirFd: New directory file descriptor.
        ///   - newPath: Null-terminated new path.
        ///   - flags: Link flags (for example, `AT_SYMLINK_FOLLOW`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func linkat(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            oldPath: UnsafePointer<CChar>,
            newDirFd: Int32,
            newPath: UnsafePointer<CChar>,
            flags: ISO_9945.Kernel.File.At.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.linkat
            target.apply(to: &self)
            unsafe self.setAddr(oldPath)
            self._rawLength = UInt32(bitPattern: newDirFd)
            unsafe self.setOffset(newPath)
            self.atFlags = flags
            self.data = data
        }

        /// Configures this entry for a fallocate operation.
        ///
        /// Preallocates or deallocates disk space for a file.
        ///
        /// - Parameters:
        ///   - target: File targeting (descriptor or registered index).
        ///   - mode: Allocation mode (for example, `.allocate()`, `.punch`, `.zero(keepSize: true)`).
        ///   - offset: Starting offset in the file.
        ///   - length: Number of bytes to allocate.
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func fallocate(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            mode: ISO_9945.Kernel.IO.Uring.File.Allocate.Mode,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            length: UInt64,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.fallocate
            target.apply(to: &self)
            // WHY: fallocate stores the length in addr because the len field is only
            // 32-bit but fallocate's length parameter is 64-bit.
            self.addr = length
            self._rawLength = UInt32(bitPattern: mode.rawBits)
            self.offset = offset
            self.data = data
        }
    }

    // MARK: - Networking

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
        /// Configures this entry for a socket creation operation.
        ///
        /// - Parameters:
        ///   - domain: Address family (for example, `.inet`, `.inet6`).
        ///   - kind: Socket kind (for example, `.stream`, `.datagram`).
        ///   - protocol: Network protocol (default: `.auto`).
        ///   - flags: Socket flags.
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func socket(
            domain: ISO_9945.Kernel.Socket.Address.Family,
            kind: ISO_9945.Kernel.Socket.Kind,
            protocol: ISO_9945.Kernel.Socket.`Protocol` = .auto,
            flags: ISO_9945.Kernel.Socket.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.create
            self.socketDomain = domain
            self.socketFlags = flags
            self.socketProtocol = `protocol`
            self.socketKind = kind
            self.data = data
        }

        /// Configures this entry for a socket bind operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - address: Pointer to socket address storage.
        ///   - length: Length of socket address.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func bind(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            address: UnsafePointer<ISO_9945.Kernel.Socket.Address.Storage>,
            length: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.bind
            target.apply(to: &self)
            unsafe self.setAddr(address)
            self.addressLength = length
            self.data = data
        }

        /// Configures this entry for a socket listen operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - backlog: Maximum pending connection queue length.
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func listen(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            backlog: Int32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.listen
            target.apply(to: &self)
            self.listenBacklog = backlog
            self.data = data
        }

        /// Configures this entry for a sendmsg operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - message: Pointer to message header (must remain valid until completion).
        ///   - flags: Message flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func send(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            message: UnsafePointer<ISO_9945.Kernel.Socket.Message.Header>,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.message.send
            target.apply(to: &self)
            unsafe self.setAddr(message)
            self._rawLength = 1
            self.messageFlags = flags
            self.data = data
        }

        /// Configures this entry for a recvmsg operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - message: Pointer to message header (kernel writes results here).
        ///   - flags: Message flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func recv(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            message: UnsafeMutablePointer<ISO_9945.Kernel.Socket.Message.Header>,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.message.receive
            target.apply(to: &self)
            unsafe self.setAddr(message)
            self._rawLength = 1
            self.messageFlags = flags
            self.data = data
        }

        /// Configures this entry for a zero-copy send operation.
        ///
        /// Transmits directly from user memory to NIC without kernel copy.
        ///
        /// Produces two CQEs: one for acceptance, one with `IORING_CQE_F_NOTIF`
        /// when the buffer is safe to reuse.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - buffer: Buffer pointer containing data to send.
        ///   - length: Number of bytes to send.
        ///   - flags: Message flags.
        ///   - transfer: Socket transfer modifier flags (stored in ioprio).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func send(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            transfer: ISO_9945.Kernel.IO.Uring.Socket.Transfer.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .send.zero.copy
            target.apply(to: &self)
            unsafe self.setAddr(buffer)
            self.len = length
            self.messageFlags = flags
            self.transferOptions = transfer
            self.data = data
        }

        /// Configures this entry for a zero-copy sendmsg operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - message: Pointer to message header (must remain valid until notification CQE).
        ///   - flags: Message flags.
        ///   - transfer: Socket transfer modifier flags (stored in ioprio).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func send(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            message: UnsafePointer<ISO_9945.Kernel.Socket.Message.Header>,
            flags: ISO_9945.Kernel.Socket.Message.Options,
            transfer: ISO_9945.Kernel.IO.Uring.Socket.Transfer.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .send.zero.msg
            target.apply(to: &self)
            unsafe self.setAddr(message)
            self._rawLength = 1
            self.messageFlags = flags
            self.transferOptions = transfer
            self.data = data
        }

        /// Configures this entry for a socket shutdown operation.
        ///
        /// - Parameters:
        ///   - target: Socket file targeting.
        ///   - how: Shutdown mode (`.read`, `.write`, or `.both`).
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func shutdown(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            how: ISO_9945.Kernel.Socket.Shutdown.Mode,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .socket.shutdown
            target.apply(to: &self)
            self.shutdownMode = how
            self.data = data
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
        public mutating func epoll(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            descriptor: borrowing ISO_9945.Kernel.Descriptor,
            operation: ISO_9945.Kernel.Event.Poll.Operation,
            event: UnsafeMutablePointer<ISO_9945.Kernel.Event.Poll.Event>?,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .epoll.ctl
            target.apply(to: &self)
            unsafe self.setAddr(event)
            self.epollOperation = operation
            self.setEpollDescriptor(descriptor)
            self.data = data
        }

        /// Configures this entry for an epoll_wait operation.
        ///
        /// - Parameters:
        ///   - target: Epoll fd targeting.
        ///   - events: Pointer to epoll event array for results.
        ///   - maxEvents: Maximum number of events to return.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func epoll(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            events: UnsafeMutablePointer<ISO_9945.Kernel.Event.Poll.Event>,
            maxEvents: Int32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .epoll.wait
            target.apply(to: &self)
            unsafe self.setAddr(events)
            self.epollMaxEvents = maxEvents
            self.data = data
        }
    }

    // MARK: - Timeout and Poll

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
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
        public mutating func timeout(
            after timespec: UnsafePointer<Linux.Kernel.Time.Specification>,
            count: UInt32 = 0,
            clock: ISO_9945.Kernel.IO.Uring.Clock = .monotonic,
            multishot: Bool = false,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.standard
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(timespec)
            self._rawLength = count
            self.configureTimeout(clock: clock, options: multishot ? .multishot : [])
            self.data = data
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
        public mutating func timeout(
            deadline timespec: UnsafePointer<Linux.Kernel.Time.Specification>,
            count: UInt32 = 0,
            clock: ISO_9945.Kernel.IO.Uring.Clock = .monotonic,
            multishot: Bool = false,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.standard
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(timespec)
            self._rawLength = count
            let options: ISO_9945.Kernel.IO.Uring.Timeout.Options = multishot ? [.absolute, .multishot] : .absolute
            self.configureTimeout(clock: clock, options: options)
            self.data = data
        }

        /// Configures this entry for a timeout removal operation.
        ///
        /// - Parameters:
        ///   - target: Operation data of the timeout to remove.
        ///   - data: Operation data to return with this operation's completion.
        @inlinable
        public mutating func timeout(
            remove target: ISO_9945.Kernel.IO.Uring.Operation.Data,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.remove
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            self.setAddr(target)
            self.data = data
        }

        /// Configures this entry for a relative link timeout operation.
        ///
        /// Must be submitted immediately after the linked SQE it guards.
        ///
        /// If the linked operation doesn't complete within the duration,
        /// it is cancelled.
        ///
        /// - Parameters:
        ///   - timespec: Pointer to timeout specification (must remain valid until completion).
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func timeout(
            link timespec: UnsafePointer<Linux.Kernel.Time.Specification>,
            clock: ISO_9945.Kernel.IO.Uring.Clock = .monotonic,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.link
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(timespec)
            self._rawLength = 1
            self.configureTimeout(clock: clock)
            self.data = data
        }

        /// Configures this entry for an absolute link timeout operation.
        ///
        /// Must be submitted immediately after the linked SQE it guards.
        ///
        /// If the linked operation doesn't complete by the deadline,
        /// it is cancelled.
        ///
        /// - Parameters:
        ///   - timespec: Pointer to timeout specification (must remain valid until completion).
        ///   - clock: Clock source for the timeout (default: `.monotonic`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func timeout(
            linkDeadline timespec: UnsafePointer<Linux.Kernel.Time.Specification>,
            clock: ISO_9945.Kernel.IO.Uring.Clock = .monotonic,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .timeout.link
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(timespec)
            self._rawLength = 1
            self.configureTimeout(clock: clock, options: .absolute)
            self.data = data
        }

        /// Configures this entry for a poll add operation.
        ///
        /// Monitors a file descriptor for events.
        ///
        /// - Parameters:
        ///   - target: File targeting for the fd to poll.
        ///   - events: Poll event mask (for example, `.in`, `.out`).
        ///   - multishot: If true, produces CQEs on every event without resubmission.
        ///   - trigger: Trigger mode — edge (default) or level.
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func poll(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            events: ISO_9945.Kernel.Event.Poll.Events,
            multishot: Bool = false,
            trigger: ISO_9945.Kernel.IO.Uring.Poll.Trigger = .edge,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .poll.add
            target.apply(to: &self)
            self.pollEvents = events
            var options = trigger.option
            if multishot { options.insert(.multishot) }
            self.pollOptions = options
            self.data = data
        }

        /// Configures this entry for a poll removal operation.
        ///
        /// - Parameters:
        ///   - target: Operation data of the poll operation to remove.
        ///   - data: Operation data to return with this operation's completion.
        @inlinable
        public mutating func poll(
            remove target: ISO_9945.Kernel.IO.Uring.Operation.Data,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .poll.remove
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            self.setAddr(target)
            self.data = data
        }
    }

    // MARK: - Control and Utility

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
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
        public mutating func message(
            ring fd: Int32,
            value: UInt32,
            targetData: ISO_9945.Kernel.IO.Uring.Operation.Data,
            flags: ISO_9945.Kernel.IO.Uring.Message.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .ring.msg
            self.messageRingFd = fd
            self.messageValue = value
            self.setMessageTarget(targetData)
            self.messageRingFlags = flags
            self.data = data
        }

        /// Configures this entry for a provide buffers operation (legacy).
        ///
        /// Provides a set of buffers to the kernel for automatic buffer selection.
        ///
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
        public mutating func provide(
            buffer: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            count: Int32,
            group: ISO_9945.Kernel.IO.Uring.Buffer.Group,
            startId: UInt16,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .buffer.provide
            self.bufferCount = count
            unsafe self.setAddr(buffer)
            self.len = length
            self.bufferStartID = startId
            self._bufferGroup = group
            self.data = data
        }

        /// Configures this entry for a remove buffers operation.
        ///
        /// - Parameters:
        ///   - count: Number of buffers to remove.
        ///   - group: Buffer group ID.
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func remove(
            bufferCount count: Int32,
            group: ISO_9945.Kernel.IO.Uring.Buffer.Group,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .buffer.remove
            self.bufferCount = count
            self._bufferGroup = group
            self.data = data
        }

        /// Configures this entry for a registered files update operation.
        ///
        /// - Parameters:
        ///   - fds: Pointer to array of file descriptors.
        ///   - count: Number of file descriptors.
        ///   - offset: Starting index in the registered file table.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func files(
            update fds: UnsafePointer<Int32>,
            count: UInt32,
            offset: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.update
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(fds)
            self._rawLength = count
            self._rawOffset = UInt64(offset)
            self.data = data
        }

        /// Configures this entry for a uring passthrough command.
        ///
        /// Passes a device-specific command through the io_uring framework
        /// (for example, NVMe passthrough).
        ///
        /// - Parameters:
        ///   - target: Device file targeting.
        ///   - op: Command opcode.
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func command(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            op: UInt32,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .ring.cmd
            target.apply(to: &self)
            self.commandOpcode = op
            self.data = data
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
        public mutating func install(
            fd: UInt32,
            flags: ISO_9945.Kernel.IO.Uring.Fixed.Install.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .fixed.install
            self._fd = Int32(bitPattern: fd)
            self.installFlags = flags
            self.data = data
        }

        /// Configures this entry for a pipe creation operation.
        ///
        /// - Parameters:
        ///   - fds: Pointer to two-element Int32 array for read/write fds.
        ///   - flags: Pipe flags (for example, `O_NONBLOCK`, `O_CLOEXEC`).
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func pipe(
            fds: UnsafeMutablePointer<Int32>,
            flags: ISO_9945.Kernel.Pipe.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .pipe.create
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(fds)
            self.pipeCreateFlags = flags
            self.data = data
        }

        /// Configures this entry for a 128-byte no-op operation.
        ///
        /// - Parameter data: Operation data to return with completion.
        @inlinable
        public mutating func nop128(data: ISO_9945.Kernel.IO.Uring.Operation.Data) {
            self = .init()
            self.opcode = .nop128
            self.data = data
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
        public mutating func waitid(
            kind: ISO_9945.Kernel.Process.Wait.Kind,
            id: ISO_9945.Kernel.Process.ID,
            info: UnsafeMutablePointer<ISO_9945.Kernel.Signal.Information>,
            options: ISO_9945.Kernel.Process.Wait.Options,
            flags: ISO_9945.Kernel.IO.Uring.Wait.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .wait.id
            self.setWaitidProcess(id)
            self.waitidKind = kind
            unsafe self.setOffset(info)
            self.waitidOptions = options
            self.waitidFlags = flags
            self.data = data
        }
    }

    // MARK: - File and Memory Advisory

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
        /// Configures this entry for a file advisory operation (fadvise).
        ///
        /// - Parameters:
        ///   - target: File targeting.
        ///   - offset: Starting offset.
        ///   - length: Length of the advisory region.
        ///   - advice: File access pattern advisory hint.
        ///   - data: Operation data to return with completion.
        @inlinable
        public mutating func fadvise(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            length: ISO_9945.Kernel.IO.Uring.Length,
            advice: ISO_9945.Kernel.File.Advice,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .file.fadvise
            target.apply(to: &self)
            self.offset = offset
            self.len = length
            self.fileAdvice = advice
            self.data = data
        }

        /// Configures this entry for a memory advisory operation (madvise).
        ///
        /// - Parameters:
        ///   - addr: Start address of the memory region.
        ///   - length: Length of the memory region.
        ///   - advice: Memory access pattern advisory hint.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func madvise(
            addr: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            advice: Memory.Map.Advice,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .memory.madvise
            ISO_9945.Kernel.IO.Uring.Target.none.apply(to: &self)
            unsafe self.setAddr(addr)
            self.len = length
            self.memoryAdvice = advice
            self.data = data
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
        public mutating func sync(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            offset: ISO_9945.Kernel.IO.Uring.Offset,
            length: ISO_9945.Kernel.IO.Uring.Length,
            flags: ISO_9945.Kernel.File.Sync.Range.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .sync.file.range
            target.apply(to: &self)
            self.offset = offset
            self.len = length
            self.syncRangeFlags = flags
            self.data = data
        }
    }

    // MARK: - Futex

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
        /// Configures this entry for a futex wait operation (kernel 6.7+).
        ///
        /// - Parameters:
        ///   - futex: Pointer to the futex word.
        ///   - value: Expected value to compare against.
        ///   - mask: Bit mask for comparison.
        ///   - flags: Futex flags.
        ///   - data: Operation data to return with completion.
        @inlinable @unsafe
        public mutating func futex(
            wait futex: UnsafePointer<UInt32>,
            value: UInt64,
            mask: UInt64,
            flags: ISO_9945.Kernel.Futex.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .futex.wait

            unsafe self.setAddr(futex)
            self.offset = ISO_9945.Kernel.IO.Uring.Offset(value)
            self.futexFlags = flags
            self._addr3 = mask
            self.data = data
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
        public mutating func futex(
            wake futex: UnsafePointer<UInt32>,
            value: UInt64,
            mask: UInt64,
            flags: ISO_9945.Kernel.Futex.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .futex.wake

            unsafe self.setAddr(futex)
            self.offset = ISO_9945.Kernel.IO.Uring.Offset(value)
            self.futexFlags = flags
            self._addr3 = mask
            self.data = data
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
        public mutating func futex(
            wait entries: UnsafePointer<ISO_9945.Kernel.Futex.Wait.Entry>,
            count: UInt32,
            flags: ISO_9945.Kernel.Futex.Options,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .futex.waitv

            unsafe self.setAddr(entries)
            self._rawLength = count
            self.futexFlags = flags
            self.data = data
        }
    }

    // MARK: - Extended Attributes

    extension ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry {
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
        public mutating func fsetxattr(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            name: UnsafePointer<CChar>,
            value: UnsafeRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            disposition: ISO_9945.Kernel.IO.Uring.File.Xattr.Disposition = .createOrReplace,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .xattr.fset
            target.apply(to: &self)
            unsafe self.setAddr(name)
            self.len = length
            unsafe self.setOffset(value)
            self.setXattrDisposition(disposition)
            self.data = data
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
        public mutating func setxattr(
            name: UnsafePointer<CChar>,
            value: UnsafeRawPointer,
            path: UnsafePointer<CChar>,
            length: ISO_9945.Kernel.IO.Uring.Length,
            disposition: ISO_9945.Kernel.IO.Uring.File.Xattr.Disposition = .createOrReplace,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .xattr.set

            unsafe self.setAddr(name)
            self.len = length
            unsafe self.setOffset(value)
            unsafe self.setAddr3(path)
            self.setXattrDisposition(disposition)
            self.data = data
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
        public mutating func fgetxattr(
            target: borrowing ISO_9945.Kernel.IO.Uring.Target,
            name: UnsafePointer<CChar>,
            value: UnsafeMutableRawPointer,
            length: ISO_9945.Kernel.IO.Uring.Length,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .xattr.fget
            target.apply(to: &self)
            unsafe self.setAddr(name)
            self.len = length
            unsafe self.setOffset(value)
            self.data = data
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
        public mutating func getxattr(
            name: UnsafePointer<CChar>,
            value: UnsafeMutableRawPointer,
            path: UnsafePointer<CChar>,
            length: ISO_9945.Kernel.IO.Uring.Length,
            data: ISO_9945.Kernel.IO.Uring.Operation.Data
        ) {
            self = .init()
            self.opcode = .xattr.get

            unsafe self.setAddr(name)
            self.len = length
            unsafe self.setOffset(value)
            unsafe self.setAddr3(path)
            self.data = data
        }
    }

#endif
