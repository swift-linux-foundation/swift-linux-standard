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
        /// if let sqe = ring.nextEntry() {
        ///     unsafe sqe.prepare.nop(data: data)
        ///     ring.advance()
        /// }
        /// let flushed = ring.flush()
        /// _ = try ring.enter(toSubmit: flushed, minComplete: .zero, flags: [])
        /// let harvested = ring.drain(limit: .init(__unchecked: (), Cardinal(256))) { cqe in
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

            // Submission tracking — local head/tail decoupled from kernel-visible tail.
            // next() advances sqeTail locally. flush() publishes [sqeHead..<sqeTail]
            // to the kernel with a single atomic store-release on sqTail.
            @usableFromInline var sqeHead: UInt32 = 0
            @usableFromInline var sqeTail: UInt32 = 0

            // Whether SQ and CQ share one mmap region (IORING_FEAT_SINGLE_MMAP).
            // When true, deinit must NOT munmap cqRingAddr separately.
            @usableFromInline let singleMmap: Bool

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
                singleMmap: Bool,
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
                self.sqeHead = 0
                self.sqeTail = 0
                self.singleMmap = singleMmap
                self.sqRingAddr = sqRingAddr; self.sqRingSize = sqRingSize
                self.cqRingAddr = cqRingAddr; self.cqRingSize = cqRingSize
                self.sqeAddr = sqeAddr; self.sqeSize = sqeSize
            }

            deinit {
                unsafe munmap(sqRingAddr.mutablePointer, Int(sqRingSize))
                // With SINGLE_MMAP, CQ shares the SQ region — do not double-munmap.
                if !singleMmap {
                    unsafe munmap(cqRingAddr.mutablePointer, Int(cqRingSize))
                }
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

    public import CPU_Primitives

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
            flags: Enter.Options
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
            flags: Enter.Options
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
            let isSingleMmap = params.features.contains(.singleMmap)

            let sqEntryCount = Int(bitPattern: params.sqEntries)
            let cqEntryCount = Int(bitPattern: params.cqEntries)
            let sqRingSz = params.sqOff.array.vector.rawValue + sqEntryCount * MemoryLayout<UInt32>.size
            let cqRingSz = params.cqOff.cqes.vector.rawValue + cqEntryCount * MemoryLayout<Kernel.IO.Uring.Completion.Queue.Entry>.size
            let sqeSz = sqEntryCount * MemoryLayout<Kernel.IO.Uring.Submission.Queue.Entry>.size

            // -- Map SQ ring --
            // With SINGLE_MMAP (kernel 5.4+), size the region to cover both SQ and CQ.

            let sqMmapSz = isSingleMmap ? max(sqRingSz, cqRingSz) : sqRingSz

            guard let sq = unsafe mmap(nil, sqMmapSz, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE, fd, 0),
                  unsafe sq != MAP_FAILED else {
                throw .setup(.posix(errno))
            }

            // -- Map CQ ring --
            // With SINGLE_MMAP the CQ ring shares the SQ region — no separate mmap.

            let cq: UnsafeMutableRawPointer
            let cqMmapSz: Int
            if isSingleMmap {
                cq = sq
                cqMmapSz = 0  // Not separately mapped.
            } else {
                cqMmapSz = cqRingSz
                guard let cqPtr = unsafe mmap(nil, cqRingSz, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE, fd, Int(Kernel.IO.Uring.Mmap.Offset.cqRing)),
                      unsafe cqPtr != MAP_FAILED else {
                    unsafe munmap(sq, sqMmapSz)
                    throw .setup(.posix(errno))
                }
                cq = cqPtr
            }

            // -- Map SQE array (always separate) --

            guard let sqe = unsafe mmap(nil, sqeSz, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE, fd, Int(Kernel.IO.Uring.Mmap.Offset.sqes)),
                  unsafe sqe != MAP_FAILED else {
                unsafe munmap(sq, sqMmapSz)
                if !isSingleMmap { unsafe munmap(cq, cqMmapSz) }
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
                singleMmap: isSingleMmap,
                sqRingAddr: unsafe Kernel.Memory.Address(sq), sqRingSize: Kernel.File.Size(sqMmapSz),
                cqRingAddr: unsafe Kernel.Memory.Address(cq), cqRingSize: Kernel.File.Size(cqMmapSz),
                sqeAddr: unsafe Kernel.Memory.Address(sqe), sqeSize: Kernel.File.Size(sqeSz)
            )
        }
    }

    // MARK: - Submission Queue Operations

    extension Kernel.IO.Uring {
        /// Acquire the next available SQE slot for filling.
        ///
        /// Returns a pointer to the SQE if a slot is available, or `nil` if the
        /// submission queue is full (submit pending entries and retry).
        ///
        /// The returned pointer is valid until the next ``flush()`` call. Fill the
        /// SQE via `sqe.prepare.read(...)` etc., then call ``advance()`` to mark it
        /// ready, and ``flush()`` to publish the batch to the kernel.
        ///
        /// ## Safety
        ///
        /// The returned pointer aliases mmap'd shared memory. The caller MUST NOT
        /// hold the pointer across a ``flush()`` + ``enter(toSubmit:minComplete:flags:)``
        /// cycle — the kernel may overwrite the SQE after submission.
        ///
        /// - Returns: Mutable pointer to the next SQE, or `nil` if full.
        @unsafe
        public mutating func nextEntry() -> UnsafeMutablePointer<Submission.Queue.Entry>? {
            // Local tail vs kernel-visible head. On SQPOLL the kernel advances sqHead
            // concurrently, so we load with acquire. Without SQPOLL the acquire is
            // harmless (TSO on x86, ldar on ARM64 — one instruction either way).
            let head = unsafe CPU.Atomic.load(sqHead, ordering: .acquiring)
            guard sqEntries.rawValue.rawValue > UInt(sqeTail &- head) else { return nil }
            let slot = sqMask.slot(for: sqeTail)
            return unsafe sqes.advanced(by: slot)
        }

        /// Mark the current SQE as ready for submission.
        ///
        /// Call after filling an SQE from ``nextEntry()``. This advances the local
        /// tail but does NOT publish to the kernel — call ``flush()`` for that.
        public mutating func advance() {
            sqeTail &+= 1
        }

        /// Flush all pending SQEs to the kernel.
        ///
        /// Populates the SQ indirection array for the range [sqeHead..<sqeTail],
        /// then publishes the new tail with a single atomic store-release. This
        /// makes ALL pending SQEs visible to the kernel in one barrier.
        ///
        /// - Returns: Number of SQEs flushed.
        public mutating func flush() -> Submission.Count {
            let localTail = sqeTail
            let flushed = localTail &- sqeHead
            var toFlush = sqeHead
            while toFlush != localTail {
                let slot = sqMask.slot(for: toFlush)
                unsafe sqArray[slot] = UInt32(slot)
                toFlush &+= 1
            }
            sqeHead = localTail

            // Single atomic store-release: makes SQE writes visible to the kernel.
            unsafe CPU.Atomic.store(sqTail, localTail, ordering: .releasing)

            return Submission.Count(__unchecked: (), Cardinal(UInt(flushed)))
        }

        /// Number of SQEs locally queued but not yet flushed to the kernel.
        public var pending: Submission.Count {
            Submission.Count(__unchecked: (), Cardinal(UInt(sqeTail &- sqeHead)))
        }
    }

    // MARK: - Completion Queue Operations

    extension Kernel.IO.Uring {
        /// Drain completed events from the CQ.
        ///
        /// Reads the CQ tail with acquire ordering (sees kernel's CQE writes),
        /// iterates available CQEs up to `limit`, then publishes the new CQ head
        /// with release ordering (frees CQ slots for the kernel).
        ///
        /// - Parameters:
        ///   - limit: Maximum number of completions to drain.
        ///   - visitor: Called for each CQE.
        /// - Returns: Number of completions drained.
        public mutating func drain(
            limit: Completion.Count,
            _ visitor: (Completion.Queue.Entry) -> Void
        ) -> Completion.Count {
            // Acquire-load tail: sees all CQE data the kernel wrote before
            // its store-release to cqTail.
            var head = unsafe cqHead.pointee  // We are the sole writer of cqHead.
            let tail = unsafe CPU.Atomic.load(cqTail, ordering: .acquiring)
            let maxCount = Int(bitPattern: limit)
            var count = 0

            while head != tail, count < maxCount {
                let slot = cqMask.slot(for: head)
                unsafe visitor(cqes[slot])
                head &+= 1
                count += 1
            }

            // Release-store head: makes consumed CQ slots available to the kernel.
            unsafe CPU.Atomic.store(cqHead, head, ordering: .releasing)
            return Completion.Count(__unchecked: (), Cardinal(UInt(count)))
        }

        /// Number of completions available without entering the kernel.
        public var completionsAvailable: Completion.Count {
            let tail = unsafe CPU.Atomic.load(cqTail, ordering: .acquiring)
            let head = unsafe cqHead.pointee
            return Completion.Count(__unchecked: (), Cardinal(UInt(tail &- head)))
        }
    }

#endif
