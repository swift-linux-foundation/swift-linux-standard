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
    @_spi(Syscall) public import Kernel_Primitives

    extension Kernel.IO {
        /// io_uring ring — owns the mmap'd SQ/CQ shared-memory regions.
        ///
        /// io_uring is a high-performance asynchronous I/O interface for Linux (kernel 5.1+).
        /// This struct IS the ring: it owns three mmap'd regions (SQ ring, CQ ring, SQE array)
        /// and provides typed access to submission and completion queues. All raw pointer
        /// arithmetic and UInt32 ring index masking is encapsulated here — consumers see typed
        /// operations only.
        ///
        /// Static methods provide policy-free syscall wrappers that operate on raw descriptors.
        /// Instance methods provide the shared-memory SQ/CQ protocol.
        ///
        /// NOT Sendable — thread-confined to the io_uring poll thread.
        ///
        /// ## Lifecycle
        ///
        /// ```swift
        /// var params = Kernel.IO.Uring.Params()
        /// let fd = try Kernel.IO.Uring.setup(entries: 256, params: &params)
        /// var ring = try Kernel.IO.Uring(descriptor: fd, params: params)
        /// ```
        ///
        /// ## Usage
        ///
        /// ```swift
        /// if let sqe = ring.nextEntry() {
        ///     sqe.pointee.prepare.nop(data: data)
        ///     ring.commitEntry()
        /// }
        /// let harvested = ring.drainCompletions(limit: 256) { cqe in
        ///     // process completion
        /// }
        /// ```
        public struct Uring: ~Copyable {

            // SQ ring (shared-memory pointers into mmap'd region)
            private let sqHead: UnsafeMutablePointer<UInt32>
            private let sqTail: UnsafeMutablePointer<UInt32>
            private let sqMask: UInt32
            private let sqEntries: UInt32
            private let sqArray: UnsafeMutablePointer<UInt32>
            private let sqes: UnsafeMutablePointer<Submission.Queue.Entry>

            // CQ ring (shared-memory pointers into mmap'd region)
            private let cqHead: UnsafeMutablePointer<UInt32>
            private let cqTail: UnsafeMutablePointer<UInt32>
            private let cqMask: UInt32
            private let cqes: UnsafePointer<Completion.Queue.Entry>

            // Submission tracking
            private var _pendingCount: UInt32 = 0

            // mmap regions (owned — deinit unmaps)
            private let sqRingAddr: Kernel.Memory.Address
            private let sqRingSize: Kernel.File.Size
            private let cqRingAddr: Kernel.Memory.Address
            private let cqRingSize: Kernel.File.Size
            private let sqeAddr: Kernel.Memory.Address
            private let sqeSize: Kernel.File.Size

            @unsafe
            init(
                sqHead: UnsafeMutablePointer<UInt32>,
                sqTail: UnsafeMutablePointer<UInt32>,
                sqMask: UInt32,
                sqEntries: UInt32,
                sqArray: UnsafeMutablePointer<UInt32>,
                sqes: UnsafeMutablePointer<Submission.Queue.Entry>,
                cqHead: UnsafeMutablePointer<UInt32>,
                cqTail: UnsafeMutablePointer<UInt32>,
                cqMask: UInt32,
                cqes: UnsafePointer<Completion.Queue.Entry>,
                sqRingAddr: Kernel.Memory.Address, sqRingSize: Kernel.File.Size,
                cqRingAddr: Kernel.Memory.Address, cqRingSize: Kernel.File.Size,
                sqeAddr: Kernel.Memory.Address, sqeSize: Kernel.File.Size
            ) {
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
                self._pendingCount = 0
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

    extension Kernel.IO.Uring {
        /// Phantom type tag for the io_uring byte space.
        ///
        /// Used to parameterize Dimension types for io_uring operations.
        /// IO.Uring uses UInt64 for offsets (with UInt64.max meaning "current position").
        public enum Space {}
    }

#endif

#if os(Linux)

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxShim)
        internal import CLinuxShim
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
            entries: UInt32,
            params: inout Params
        ) throws(Error) -> Kernel.Descriptor {
            var cParams = params.cValue
            let fd = swift_io_uring_setup(entries, &cParams)
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
            toSubmit: UInt32,
            minComplete: UInt32,
            flags: Enter.Flags
        ) throws(Error) -> Int {
            let result = swift_io_uring_enter(
                fd._rawValue,
                toSubmit,
                minComplete,
                flags.rawValue,
                nil,
                0
            )
            guard result >= 0 else {
                let code = Kernel.Error.Code.posix(errno)
                if code.posix == EINTR { throw .interrupted }
                throw .enter(code)
            }
            return Int(result)
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
        ) throws(Error) {
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
            descriptor: borrowing Kernel.Descriptor,
            params: Kernel.IO.Uring.Params
        ) throws(Kernel.IO.Uring.Error) {
            let fd = descriptor._rawValue

            let sqRingSz = Int(params.sqOff.array) + Int(params.sqEntries) * MemoryLayout<UInt32>.size
            let cqRingSz = Int(params.cqOff.cqes) + Int(params.cqEntries) * MemoryLayout<Kernel.IO.Uring.Completion.Queue.Entry>.size
            let sqeSz = Int(params.sqEntries) * MemoryLayout<Kernel.IO.Uring.Submission.Queue.Entry>.size

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

            unsafe self.init(
                sqHead: sq.advanced(by: Int(params.sqOff.head)).assumingMemoryBound(to: UInt32.self),
                sqTail: sq.advanced(by: Int(params.sqOff.tail)).assumingMemoryBound(to: UInt32.self),
                sqMask: sq.advanced(by: Int(params.sqOff.ringMask)).load(as: UInt32.self),
                sqEntries: params.sqEntries,
                sqArray: sq.advanced(by: Int(params.sqOff.array)).assumingMemoryBound(to: UInt32.self),
                sqes: sqe.assumingMemoryBound(to: Kernel.IO.Uring.Submission.Queue.Entry.self),
                cqHead: cq.advanced(by: Int(params.cqOff.head)).assumingMemoryBound(to: UInt32.self),
                cqTail: cq.advanced(by: Int(params.cqOff.tail)).assumingMemoryBound(to: UInt32.self),
                cqMask: cq.advanced(by: Int(params.cqOff.ringMask)).load(as: UInt32.self),
                cqes: UnsafePointer(cq.advanced(by: Int(params.cqOff.cqes))
                    .assumingMemoryBound(to: Kernel.IO.Uring.Completion.Queue.Entry.self)),
                sqRingAddr: unsafe Kernel.Memory.Address(sq), sqRingSize: Kernel.File.Size(sqRingSz),
                cqRingAddr: unsafe Kernel.Memory.Address(cq), cqRingSize: Kernel.File.Size(cqRingSz),
                sqeAddr: unsafe Kernel.Memory.Address(sqe), sqeSize: Kernel.File.Size(sqeSz)
            )
        }
    }

    // MARK: - Submission Queue Operations

    extension Kernel.IO.Uring {
        /// The number of SQEs awaiting flush via ``enter(_:toSubmit:minComplete:flags:)``.
        public var pendingSubmissions: UInt32 { _pendingCount }

        /// Acquire the next available SQE slot for filling.
        ///
        /// Returns a pointer to the SQE if a slot is available, or `nil`
        /// if the submission queue is full. After filling the SQE, call
        /// ``commitEntry()`` to advance the tail.
        ///
        /// - Returns: Mutable pointer to the next SQE, or `nil` if full.
        @unsafe
        public mutating func nextEntry() -> UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>? {
            let tail = unsafe sqTail.pointee
            guard unsafe sqEntries &- (tail &- sqHead.pointee) > 0 else { return nil }
            let idx = Int(tail & sqMask)
            unsafe sqArray[idx] = UInt32(idx)
            return unsafe sqes.advanced(by: idx)
        }

        /// Advance the SQ tail after filling an entry from ``nextEntry()``.
        ///
        /// NOTE: `io_uring_enter` provides a full memory barrier on flush.
        /// WHEN TO REMOVE: add atomic store-release if submissions cross threads.
        public mutating func commitEntry() {
            unsafe sqTail.pointee = sqTail.pointee &+ 1
            _pendingCount &+= 1
        }

        /// Reset the pending count after a successful ``enter(_:toSubmit:minComplete:flags:)``.
        public mutating func resetPending() {
            _pendingCount = 0
        }
    }

    // MARK: - Completion Queue Operations

    extension Kernel.IO.Uring {
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
        public mutating func drainCompletions(
            limit: Int,
            _ visitor: (Kernel.IO.Uring.Completion.Queue.Entry) -> Void
        ) -> Int {
            var head = unsafe cqHead.pointee
            let tail = unsafe cqTail.pointee
            var count = 0

            while head != tail, count < limit {
                unsafe visitor(cqes[Int(head & cqMask)])
                head &+= 1
                count += 1
            }

            unsafe (cqHead.pointee = head)
            return count
        }
    }

#endif
