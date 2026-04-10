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

    extension Kernel.IO {
        /// io_uring ring — owns the ring descriptor and mmap'd SQ/CQ shared-memory regions.
        ///
        /// io_uring is a high-performance asynchronous I/O interface for Linux (kernel 5.1+).
        /// This struct IS the ring: it owns the ring file descriptor, three mmap'd regions
        /// (SQ ring, CQ ring, SQE array), and provides typed access to submission and
        /// completion queues. All raw pointer arithmetic and UInt32 ring index masking is
        /// encapsulated here — consumers see typed operations only.
        ///
        /// Instance methods provide both descriptor-bound syscalls (``enter(toSubmit:minComplete:flags:)``,
        /// ``register(opcode:argument:count:)``) and the shared-memory SQ/CQ protocol.
        /// Static methods remain available for detached-descriptor workflows.
        ///
        /// NOT Sendable — thread-confined to the io_uring poll thread.
        ///
        /// ## Lifecycle
        ///
        /// ```swift
        /// var params = Kernel.IO.Uring.Params()
        /// let fd = try Kernel.IO.Uring.setup(entries: .init(__unchecked: (), Cardinal(256)), params: &params)
        /// var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)
        /// // ring now owns the descriptor — deinit unmaps regions then closes fd
        /// ```
        ///
        /// ## Usage
        ///
        /// ```swift
        /// if let sqe = ring.submission.next() {
        ///     sqe.prepare.nop(data: data)
        ///     ring.submission.commit()
        /// }
        /// _ = try ring.enter(toSubmit: ring.submission.pending, minComplete: .zero, flags: [])
        /// let harvested = ring.completion.drain(limit: .init(__unchecked: (), Cardinal(256))) { cqe in
        ///     // process completion
        /// }
        /// ```
        public struct Uring: ~Copyable {

            // Ring descriptor (owned — deinit closes fd after regions are unmapped).
            // The explicit deinit body unmaps mmap'd regions first; then stored-
            // property destruction closes the descriptor.
            @usableFromInline let ringDescriptor: Kernel.Descriptor

            // SQ ring (shared-memory pointers into mmap'd region)
            @usableFromInline let sqHead: UnsafeMutablePointer<UInt32>
            @usableFromInline let sqTail: UnsafeMutablePointer<UInt32>
            @usableFromInline let sqMask: Submission.Queue.Mask
            @usableFromInline let sqEntries: Submission.Count
            @usableFromInline let sqArray: UnsafeMutablePointer<UInt32>
            @usableFromInline let sqes: UnsafeMutablePointer<Submission.Queue.Entry>

            // CQ ring (shared-memory pointers into mmap'd region)
            @usableFromInline let cqHead: UnsafeMutablePointer<UInt32>
            @usableFromInline let cqTail: UnsafeMutablePointer<UInt32>
            @usableFromInline let cqMask: Completion.Queue.Mask
            @usableFromInline let cqes: UnsafePointer<Completion.Queue.Entry>

            // Submission tracking
            @usableFromInline var _pendingCount: Submission.Count = .zero

            // mmap regions (owned — deinit unmaps)
            @usableFromInline let sqRingAddr: Kernel.Memory.Address
            @usableFromInline let sqRingSize: Kernel.File.Size
            @usableFromInline let cqRingAddr: Kernel.Memory.Address
            @usableFromInline let cqRingSize: Kernel.File.Size
            @usableFromInline let sqeAddr: Kernel.Memory.Address
            @usableFromInline let sqeSize: Kernel.File.Size

            @unsafe
            init(
                ringDescriptor: consuming Kernel.Descriptor,
                sqHead: UnsafeMutablePointer<UInt32>,
                sqTail: UnsafeMutablePointer<UInt32>,
                sqMask: Submission.Queue.Mask,
                sqEntries: Submission.Count,
                sqArray: UnsafeMutablePointer<UInt32>,
                sqes: UnsafeMutablePointer<Submission.Queue.Entry>,
                cqHead: UnsafeMutablePointer<UInt32>,
                cqTail: UnsafeMutablePointer<UInt32>,
                cqMask: Completion.Queue.Mask,
                cqes: UnsafePointer<Completion.Queue.Entry>,
                sqRingAddr: Kernel.Memory.Address, sqRingSize: Kernel.File.Size,
                cqRingAddr: Kernel.Memory.Address, cqRingSize: Kernel.File.Size,
                sqeAddr: Kernel.Memory.Address, sqeSize: Kernel.File.Size
            ) {
                self.ringDescriptor = consume ringDescriptor
                self.sqHead = sqHead
                self.sqTail = sqTail
                self.sqMask = sqMask
                self.sqEntries = sqEntries
                self.sqArray = sqArray
                self.sqes = sqes
                self.cqHead = cqHead
                self.cqTail = cqTail
                self.cqMask = cqMask
                self.cqes = cqes
                self._pendingCount = .zero
                self.sqRingAddr = sqRingAddr; self.sqRingSize = sqRingSize
                self.cqRingAddr = cqRingAddr; self.cqRingSize = cqRingSize
                self.sqeAddr = sqeAddr; self.sqeSize = sqeSize
            }

            deinit {
                unsafe munmap(sqRingAddr.mutablePointer, Int(sqRingSize))
                unsafe munmap(cqRingAddr.mutablePointer, Int(cqRingSize))
                unsafe munmap(sqeAddr.mutablePointer, Int(sqeSize))
            }
        }
    }

    // Space is declared in Linux.Kernel.IO.Uring.Space.swift

#endif

#if os(Linux)

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    // MARK: - Syscalls

    extension Kernel.IO.Uring {
        /// Creates a new io_uring instance.
        ///
        /// - Parameters:
        ///   - entries: Number of SQ entries (rounded up to power of 2).
        ///   - params: Parameters struct (modified on return with ring offsets).
        /// - Returns: File descriptor for the io_uring instance.
        /// - Throws: `Error.setup` if creation fails.
        ///
        /// ## Blocking Behavior
        ///
        /// This method performs a blocking syscall. Call from a blocking context
        /// (dedicated thread pool), not the Swift cooperative thread pool.
        ///
        /// ## Cancellation
        ///
        /// Not cancellable once the syscall begins. Check task cancellation
        /// before calling if cooperative cancellation is needed.
        public static func setup(
            entries: Submission.Count,
            params: inout Params
        ) throws(Kernel.IO.Uring.Error) -> Kernel.Descriptor {
            var cParams = params.cValue
            let fd = swift_io_uring_setup(UInt32(entries.rawValue.rawValue), &cParams)
            guard fd >= 0 else {
                throw .setup(.posix(errno))
            }
            // Update params with kernel-filled values
            params = Params(cParams)
            return Kernel.Descriptor(_rawValue: fd)
        }

        /// Submits operations and/or waits for completions.
        ///
        /// - Parameters:
        ///   - fd: io_uring file descriptor.
        ///   - toSubmit: Number of SQEs to submit.
        ///   - minComplete: Minimum completions to wait for.
        ///   - flags: Enter flags.
        /// - Returns: Number of SQEs submitted.
        /// - Throws: `Error.enter` on failure, `Error.interrupted` on EINTR.
        ///
        /// ## Blocking Behavior
        ///
        /// May block if `minComplete > 0` or if `.getEvents` flag is set.
        /// Call from a blocking context (dedicated thread pool), not the
        /// Swift cooperative thread pool.
        ///
        /// ## Cancellation
        ///
        /// If interrupted by a signal, throws `Error.interrupted`. Callers
        /// should typically retry on interruption unless cancellation is desired.
        public static func enter(
            _ fd: borrowing Kernel.Descriptor,
            toSubmit: Submission.Count,
            minComplete: Completion.Count,
            flags: Enter.Flags
        ) throws(Kernel.IO.Uring.Error) -> Submission.Count {
            let result = swift_io_uring_enter(
                fd._rawValue,
                UInt32(toSubmit.rawValue.rawValue),
                UInt32(minComplete.rawValue.rawValue),
                flags.rawValue,
                nil,
                0
            )
            guard result >= 0 else {
                let code = Kernel.Error.Code.posix(errno)
                if code.posix == EINTR { throw .interrupted }
                throw .enter(code)
            }
            return Submission.Count(__unchecked: (), Cardinal(UInt(result)))
        }

        /// Registers resources with the io_uring instance.
        ///
        /// - Parameters:
        ///   - fd: io_uring file descriptor.
        ///   - opcode: The registration operation to perform.
        ///   - argument: Pointer to the arguments for the operation.
        ///   - count: Number of arguments.
        /// - Throws: `Error.register` on failure.
        ///
        /// ## Blocking Behavior
        ///
        /// This method performs a blocking syscall. Call from a blocking context
        /// (dedicated thread pool), not the Swift cooperative thread pool.
        ///
        /// ## Cancellation
        ///
        /// Not cancellable once the syscall begins. Check task cancellation
        /// before calling if cooperative cancellation is needed.
        @unsafe
        public static func register(
            _ fd: borrowing Kernel.Descriptor,
            opcode: Register.Opcode,
            argument: UnsafeMutableRawPointer?,
            count: UInt32
        ) throws(Kernel.IO.Uring.Error) {
            let result = unsafe swift_io_uring_register(
                fd._rawValue,
                opcode.rawValue,
                argument,
                count
            )
            guard result >= 0 else {
                throw .register(.posix(errno))
            }
        }

        /// Closes an io_uring instance.
        ///
        /// Uses `Kernel.Close.close()` for consistency. Ignores errors.
        ///
        /// - Parameter fd: The io_uring file descriptor to close.
        ///
        /// ## Blocking Behavior
        ///
        /// This method performs a blocking syscall but typically completes quickly.
        ///
        /// ## Shutdown
        ///
        /// Closing the ring immediately invalidates all pending submissions and
        /// completions. Ensure all in-flight operations are completed or cancelled
        /// before closing.
        public static func close(_ fd: consuming Kernel.Descriptor) {
            try? Kernel.Close.close(consume fd)
        }
    }

    // MARK: - Instance API (descriptor-bound)

    extension Kernel.IO.Uring {
        /// Submit pending operations and/or wait for completions using the
        /// ring's owned descriptor.
        ///
        /// - Parameters:
        ///   - toSubmit: Number of SQEs to submit.
        ///   - minComplete: Minimum completions to wait for.
        ///   - flags: Enter flags.
        /// - Returns: Number of SQEs submitted.
        /// - Throws: `Error.enter` on failure, `Error.interrupted` on EINTR.
        public func enter(
            toSubmit: Submission.Count,
            minComplete: Completion.Count,
            flags: Enter.Flags
        ) throws(Error) -> Submission.Count {
            try Self.enter(
                ringDescriptor,
                toSubmit: toSubmit,
                minComplete: minComplete,
                flags: flags
            )
        }

        /// Raw register — internal escape hatch for typed public methods.
        @unsafe
        internal func register(
            opcode: Register.Opcode,
            argument: UnsafeMutableRawPointer?,
            count: UInt32
        ) throws(Error) {
            try unsafe Self.register(
                ringDescriptor,
                opcode: opcode,
                argument: argument,
                count: count
            )
        }

        /// Register an eventfd for completion notifications.
        ///
        /// The eventfd is signaled when completions arrive, enabling
        /// integration with poll-based event loops (epoll).
        ///
        /// - Parameter descriptor: The eventfd file descriptor.
        /// - Throws: `Error.register` on failure.
        public func register(
            eventfd descriptor: borrowing Kernel.Descriptor
        ) throws(Error) {
            var fd = descriptor._rawValue
            try unsafe withUnsafeMutablePointer(to: &fd) {
                (ptr: UnsafeMutablePointer<Int32>) throws(Error) in
                try unsafe self.register(
                    opcode: .eventfd.register,
                    argument: ptr,
                    count: 1
                )
            }
        }
    }

    // MARK: - Factory

    extension Kernel.IO.Uring {
        /// Create a ring by mmap'ing the io_uring shared-memory regions.
        ///
        /// Maps three regions (SQ ring, CQ ring, SQE array) using the
        /// offsets and sizes from kernel-filled params. On partial failure,
        /// cleans up acquired regions before throwing.
        ///
        /// - Parameters:
        ///   - descriptor: The io_uring file descriptor from ``setup(entries:params:)``.
        ///   - params: Kernel-filled params containing ring offsets and sizes.
        /// - Throws: ``Error/setup(_:)`` on mmap failure.
        public init(
            descriptor: consuming Kernel.Descriptor,
            params: Kernel.IO.Uring.Params
        ) throws(Kernel.IO.Uring.Error) {
            let fd = descriptor._rawValue

            let sqEntryCount = Int(bitPattern: params.sqEntries)
            let cqEntryCount = Int(bitPattern: params.cqEntries)
            let sqRingSz = params.sqOff.array.vector.rawValue + sqEntryCount * MemoryLayout<UInt32>.size
            let cqRingSz = params.cqOff.cqes.vector.rawValue + cqEntryCount * MemoryLayout<Kernel.IO.Uring.Completion.Queue.Entry>.size
            let sqeSz = sqEntryCount * MemoryLayout<Kernel.IO.Uring.Submission.Queue.Entry>.size

            // -- Map SQ ring --

            guard let sq = unsafe mmap(nil, sqRingSz, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE, fd, 0),
                  unsafe sq != MAP_FAILED else {
                throw .setup(.posix(errno))
            }

            // -- Map CQ ring --

            guard let cq = unsafe mmap(nil, cqRingSz, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE, fd, Int(Kernel.IO.Uring.Mmap.Offset.cqRing)),
                  unsafe cq != MAP_FAILED else {
                unsafe munmap(sq, sqRingSz)
                throw .setup(.posix(errno))
            }

            // -- Map SQE array --

            guard let sqe = unsafe mmap(nil, sqeSz, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE, fd, Int(Kernel.IO.Uring.Mmap.Offset.sqes)),
                  unsafe sqe != MAP_FAILED else {
                unsafe munmap(sq, sqRingSz)
                unsafe munmap(cq, cqRingSz)
                throw .setup(.posix(errno))
            }

            // WHY: .vector.rawValue extracts Int from Memory.Address.Offset for stdlib
            // pointer arithmetic. Memory Primitives Standard Library Integration provides
            // typed overloads but isn't in the dependency chain.
            // WHEN TO REMOVE: when kernel-primitives re-exports the integration module.
            unsafe self.init(
                ringDescriptor: consume descriptor,
                sqHead: sq.advanced(by: params.sqOff.head.vector.rawValue).assumingMemoryBound(to: UInt32.self),
                sqTail: sq.advanced(by: params.sqOff.tail.vector.rawValue).assumingMemoryBound(to: UInt32.self),
                sqMask: Submission.Queue.Mask(rawValue: sq.load(fromByteOffset: params.sqOff.ringMask.vector.rawValue, as: UInt32.self)),
                sqEntries: params.sqEntries,
                sqArray: sq.advanced(by: params.sqOff.array.vector.rawValue).assumingMemoryBound(to: UInt32.self),
                sqes: sqe.assumingMemoryBound(to: Kernel.IO.Uring.Submission.Queue.Entry.self),
                cqHead: cq.advanced(by: params.cqOff.head.vector.rawValue).assumingMemoryBound(to: UInt32.self),
                cqTail: cq.advanced(by: params.cqOff.tail.vector.rawValue).assumingMemoryBound(to: UInt32.self),
                cqMask: Completion.Queue.Mask(rawValue: cq.load(fromByteOffset: params.cqOff.ringMask.vector.rawValue, as: UInt32.self)),
                cqes: UnsafePointer(cq.advanced(by: params.cqOff.cqes.vector.rawValue)
                    .assumingMemoryBound(to: Kernel.IO.Uring.Completion.Queue.Entry.self)),
                sqRingAddr: unsafe Kernel.Memory.Address(sq), sqRingSize: Kernel.File.Size(sqRingSz),
                cqRingAddr: unsafe Kernel.Memory.Address(cq), cqRingSize: Kernel.File.Size(cqRingSz),
                sqeAddr: unsafe Kernel.Memory.Address(sqe), sqeSize: Kernel.File.Size(sqeSz)
            )
        }
    }

    // MARK: - Submission Queue Operations

    extension Kernel.IO.Uring {
        /// Submission queue operations.
        public var submission: Submission.Access {
            mutating get {
                unsafe Submission.Access(ring: &self)
            }
        }
    }

    extension Kernel.IO.Uring.Submission {
        /// Accessor for submission queue operations on the ring.
        public struct Access: ~Copyable {
            @usableFromInline
            let ring: UnsafeMutablePointer<Kernel.IO.Uring>

            @unsafe @usableFromInline
            init(ring: UnsafeMutablePointer<Kernel.IO.Uring>) {
                self.ring = unsafe ring
            }
        }
    }

    extension Kernel.IO.Uring.Submission.Access {
        /// The number of SQEs awaiting flush via ``Kernel/IO/Uring/enter(toSubmit:minComplete:flags:)``.
        public var pending: Kernel.IO.Uring.Submission.Count {
            unsafe ring.pointee._pendingCount
        }

        /// Acquire the next available SQE slot for filling.
        ///
        /// Returns a pointer to the SQE if a slot is available, or `nil`
        /// if the submission queue is full. After filling the SQE, call
        /// ``commit()`` to advance the tail.
        ///
        /// - Returns: Mutable pointer to the next SQE, or `nil` if full.
        @unsafe
        public func next() -> UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>? {
            let tail = unsafe ring.pointee.sqTail.pointee
            let head = unsafe ring.pointee.sqHead.pointee
            let used = Kernel.IO.Uring.Submission.Count(__unchecked: (), Cardinal(UInt(tail &- head)))
            guard used < ring.pointee.sqEntries else { return nil }
            let slot = ring.pointee.sqMask.slot(for: tail)
            unsafe ring.pointee.sqArray[slot] = UInt32(slot)
            return unsafe ring.pointee.sqes.advanced(by: slot)
        }

        /// Advance the SQ tail after filling an entry from ``next()``.
        ///
        /// NOTE: `io_uring_enter` provides a full memory barrier on flush.
        /// WHEN TO REMOVE: add atomic store-release if submissions cross threads.
        public func commit() {
            unsafe ring.pointee.sqTail.pointee = ring.pointee.sqTail.pointee &+ 1
            unsafe (ring.pointee._pendingCount += .one)
        }

        /// Reset the pending count after a successful enter call.
        public func reset() {
            unsafe (ring.pointee._pendingCount = .zero)
        }
    }

    // MARK: - Completion Queue Operations

    extension Kernel.IO.Uring {
        /// Completion queue operations.
        public var completion: Completion.Access {
            mutating get {
                unsafe Completion.Access(ring: &self)
            }
        }
    }

    extension Kernel.IO.Uring.Completion {
        /// Accessor for completion queue operations on the ring.
        public struct Access: ~Copyable {
            @usableFromInline
            let ring: UnsafeMutablePointer<Kernel.IO.Uring>

            @unsafe @usableFromInline
            init(ring: UnsafeMutablePointer<Kernel.IO.Uring>) {
                self.ring = unsafe ring
            }
        }
    }

    extension Kernel.IO.Uring.Completion.Access {
        /// Drain completed events from the CQ.
        ///
        /// Iterates available CQEs up to `limit`, calling `visitor` for each.
        /// Advances the CQ head after all entries are processed.
        ///
        /// Non-blocking shared-memory read.
        ///
        /// NOTE: `io_uring_enter` on flush provides the memory barrier for the next cycle.
        /// WHEN TO REMOVE: add atomic store-release if harvest crosses threads.
        ///
        /// - Parameters:
        ///   - limit: Maximum number of completions to drain.
        ///   - visitor: Called for each CQE.
        /// - Returns: Number of completions drained.
        public func drain(
            limit: Kernel.IO.Uring.Completion.Count,
            _ visitor: (Kernel.IO.Uring.Completion.Queue.Entry) -> Void
        ) -> Kernel.IO.Uring.Completion.Count {
            var head = unsafe ring.pointee.cqHead.pointee
            let tail = unsafe ring.pointee.cqTail.pointee
            let maxCount = Int(bitPattern: limit)
            var count = 0

            while head != tail, count < maxCount {
                let slot = ring.pointee.cqMask.slot(for: head)
                unsafe visitor(ring.pointee.cqes[slot])
                head &+= 1
                count += 1
            }

            unsafe (ring.pointee.cqHead.pointee = head)
            return Kernel.IO.Uring.Completion.Count(__unchecked: (), Cardinal(UInt(count)))
        }
    }

#endif
