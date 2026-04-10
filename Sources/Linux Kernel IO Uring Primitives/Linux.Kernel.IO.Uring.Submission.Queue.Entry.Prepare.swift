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
        ///   - fd: File descriptor to read from.
        ///   - buffer: Buffer pointer to read into.
        ///   - length: Number of bytes to read.
        ///   - offset: File offset (use `.current` for current position).
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func read(
            fd: borrowing Kernel.Descriptor,
            buffer: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .read.standard)
            unsafe (pointer.pointee.cValue.fd = fd._rawValue)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.offset = offset)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a write operation.
        ///
        /// - Parameters:
        ///   - fd: File descriptor to write to.
        ///   - buffer: Buffer pointer containing data to write.
        ///   - length: Number of bytes to write.
        ///   - offset: File offset (use `.current` for current position).
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func write(
            fd: borrowing Kernel.Descriptor,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            offset: Kernel.IO.Uring.Offset,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .write.standard)
            unsafe (pointer.pointee.cValue.fd = fd._rawValue)
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
        ///   - fd: File descriptor to sync.
        ///   - datasync: If true, only sync data (not metadata).
        ///   - data: Operation data to return with completion.
        @inlinable
        public func fsync(
            fd: borrowing Kernel.Descriptor,
            datasync: Bool,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .sync.file)
            unsafe (pointer.pointee.cValue.fd = fd._rawValue)
            if datasync {
                unsafe (pointer.pointee.opFlags = 1)  // IORING_FSYNC_DATASYNC
            }
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a close operation.
        ///
        /// - Parameters:
        ///   - fd: File descriptor to close.
        ///   - data: Operation data to return with completion.
        @inlinable
        public func close(
            fd: borrowing Kernel.Descriptor,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .close)
            unsafe (pointer.pointee.cValue.fd = fd._rawValue)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for an accept operation.
        ///
        /// - Parameters:
        ///   - fd: Listening socket file descriptor.
        ///   - addr: Optional pointer to sockaddr buffer.
        ///   - addrLen: Optional pointer to sockaddr length.
        ///   - flags: Accept flags.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func accept(
            fd: borrowing Kernel.Descriptor,
            addr: UnsafeMutableRawPointer?,
            addrLen: UnsafeMutablePointer<UInt32>?,
            flags: Int32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.accept)
            unsafe (pointer.pointee.cValue.fd = fd._rawValue)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: addr)))
            unsafe (pointer.pointee.offset = Kernel.IO.Uring.Offset(UInt64(UInt(bitPattern: addrLen))))
            unsafe (pointer.pointee.opFlags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a connect operation.
        ///
        /// - Parameters:
        ///   - fd: Socket file descriptor.
        ///   - addr: Pointer to sockaddr.
        ///   - addrLen: Length of sockaddr.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func connect(
            fd: borrowing Kernel.Descriptor,
            addr: UnsafeRawPointer,
            addrLen: UInt32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.connect)
            unsafe (pointer.pointee.cValue.fd = fd._rawValue)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: addr)))
            unsafe (pointer.pointee.offset = Kernel.IO.Uring.Offset(UInt64(addrLen)))
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a send operation.
        ///
        /// - Parameters:
        ///   - fd: Socket file descriptor.
        ///   - buffer: Buffer pointer containing data to send.
        ///   - length: Number of bytes to send.
        ///   - flags: Send flags.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func send(
            fd: borrowing Kernel.Descriptor,
            buffer: UnsafeRawPointer,
            length: Kernel.IO.Uring.Length,
            flags: Int32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.send)
            unsafe (pointer.pointee.cValue.fd = fd._rawValue)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.opFlags = flags)
            unsafe (pointer.pointee.data = data)
        }

        /// Configures this entry for a recv operation.
        ///
        /// - Parameters:
        ///   - fd: Socket file descriptor.
        ///   - buffer: Buffer pointer to receive into.
        ///   - length: Maximum bytes to receive.
        ///   - flags: Recv flags.
        ///   - data: Operation data to return with completion.
        @unsafe @inlinable
        public func recv(
            fd: borrowing Kernel.Descriptor,
            buffer: UnsafeMutableRawPointer,
            length: Kernel.IO.Uring.Length,
            flags: Int32,
            data: Kernel.IO.Uring.Operation.Data
        ) {
            unsafe (pointer.pointee.cValue = io_uring_sqe())
            unsafe (pointer.pointee.opcode = .socket.receive)
            unsafe (pointer.pointee.cValue.fd = fd._rawValue)
            unsafe (pointer.pointee.addr = UInt64(UInt(bitPattern: buffer)))
            unsafe (pointer.pointee.len = length)
            unsafe (pointer.pointee.opFlags = flags)
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
        /// unsafe sqe.prepare.read(fd: fd, buffer: buf, length: len, offset: .zero, data: id)
        /// ```
        @unsafe
        public var prepare: Pointee.Prepare {
            unsafe Pointee.Prepare(self)
        }
    }

#endif
