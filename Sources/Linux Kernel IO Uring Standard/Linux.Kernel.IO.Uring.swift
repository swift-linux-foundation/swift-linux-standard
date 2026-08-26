#if os(Linux)

    @_spi(Syscall) public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error
    public import Memory

    public import CPU

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        internal import Linux_Kernel_Shims
    #endif

    extension ISO_9945.Kernel.IO {

        public struct Uring: ~Copyable {

            @usableFromInline let ringDescriptor: ISO_9945.Kernel.Descriptor

            @usableFromInline let sqHead: UnsafeMutablePointer<UInt32>
            @usableFromInline let sqTail: UnsafeMutablePointer<UInt32>
            @usableFromInline let sqMask: Submission.Queue.Mask
            @usableFromInline let sqEntries: Submission.Count
            @usableFromInline let sqArray: UnsafeMutablePointer<UInt32>
            @usableFromInline let sqes: UnsafeMutablePointer<Submission.Queue.Entry>

            @usableFromInline let cqHead: UnsafeMutablePointer<UInt32>
            @usableFromInline let cqTail: UnsafeMutablePointer<UInt32>
            @usableFromInline let cqMask: Completion.Queue.Mask
            @usableFromInline let cqes: UnsafePointer<Completion.Queue.Entry>

            @usableFromInline var sqeHead: UInt32 = 0
            @usableFromInline var sqeTail: UInt32 = 0

            @usableFromInline let singleMmap: Bool

            @usableFromInline let sqRingAddr: Memory.Memory.Address
            @usableFromInline let sqRingSize: ISO_9945.Kernel.File.Size
            @usableFromInline let cqRingAddr: Memory.Memory.Address
            @usableFromInline let cqRingSize: ISO_9945.Kernel.File.Size
            @usableFromInline let sqeAddr: Memory.Memory.Address
            @usableFromInline let sqeSize: ISO_9945.Kernel.File.Size

            @unsafe
            init(
                ringDescriptor: consuming ISO_9945.Kernel.Descriptor,
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
                sqRingAddr: Memory.Memory.Address,
                sqRingSize: ISO_9945.Kernel.File.Size,
                cqRingAddr: Memory.Memory.Address,
                cqRingSize: ISO_9945.Kernel.File.Size,
                sqeAddr: Memory.Memory.Address,
                sqeSize: ISO_9945.Kernel.File.Size
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
                self.sqRingAddr = sqRingAddr
                self.sqRingSize = sqRingSize
                self.cqRingAddr = cqRingAddr
                self.cqRingSize = cqRingSize
                self.sqeAddr = sqeAddr
                self.sqeSize = sqeSize
            }

            deinit {
                unsafe munmap(sqRingAddr.mutablePointer, Int(sqRingSize))

                if !singleMmap {
                    unsafe munmap(cqRingAddr.mutablePointer, Int(cqRingSize))
                }
                unsafe munmap(sqeAddr.mutablePointer, Int(sqeSize))
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring {

        public static func setup(
            entries: Submission.Count,
            params: inout Params
        ) throws(ISO_9945.Kernel.IO.Uring.Error) -> ISO_9945.Kernel.Descriptor {
            var cParams = params.cValue
            let fd = swift_io_uring_setup(UInt32(entries.underlying.rawValue), &cParams)
            guard fd >= 0 else {
                throw .setup(.posix(errno))
            }

            params = Params(cParams)
            return ISO_9945.Kernel.Descriptor(_rawValue: fd)
        }

        public static func enter(
            _ fd: borrowing ISO_9945.Kernel.Descriptor,
            toSubmit: Submission.Count,
            minComplete: Completion.Count,
            flags: Enter.Options
        ) throws(ISO_9945.Kernel.IO.Uring.Error) -> Submission.Count {
            let result = swift_io_uring_enter(
                fd._rawValue,
                UInt32(toSubmit.underlying.rawValue),
                UInt32(minComplete.underlying.rawValue),
                flags.rawValue,
                nil,
                0
            )
            guard result >= 0 else {
                let code = Error.Error.Code.posix(errno)
                if code.posix == EINTR { throw .interrupted }
                throw .enter(code)
            }
            return Submission.Count(_unchecked: Cardinal(UInt(result)))
        }

        @unsafe
        public static func register(
            _ fd: borrowing ISO_9945.Kernel.Descriptor,
            opcode: Register.Opcode,
            argument: UnsafeMutableRawPointer?,
            count: UInt32
        ) throws(ISO_9945.Kernel.IO.Uring.Error) {
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

        public static func close(_ fd: consuming ISO_9945.Kernel.Descriptor) {
            do throws(ISO_9945.Kernel.Close.Error) {
                try ISO_9945.Kernel.Close.close(consume fd)
            } catch {

            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring {

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

        public func register(
            eventfd descriptor: borrowing ISO_9945.Kernel.Descriptor
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

    extension ISO_9945.Kernel.IO.Uring {

        public init(
            descriptor: consuming ISO_9945.Kernel.Descriptor,
            params: ISO_9945.Kernel.IO.Uring.Params
        ) throws(ISO_9945.Kernel.IO.Uring.Error) {
            let fd = descriptor._rawValue
            let isSingleMmap = params.features.contains(.singleMmap)

            let sqEntryCount = Int(bitPattern: params.sqEntries)
            let cqEntryCount = Int(bitPattern: params.cqEntries)
            let sqRingSz =
                params.sqOff.array.vector.rawValue + sqEntryCount * MemoryLayout<UInt32>.size
            let cqRingSz =
                params.cqOff.cqes.vector.rawValue + cqEntryCount
                * MemoryLayout<ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry>.size
            let sqeSz =
                sqEntryCount * MemoryLayout<ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry>.size

            let sqMmapSz = isSingleMmap ? max(sqRingSz, cqRingSz) : sqRingSz

            guard
                let sq = unsafe mmap(
                    nil,
                    sqMmapSz,
                    PROT_READ | PROT_WRITE,
                    MAP_SHARED | MAP_POPULATE,
                    fd,
                    0
                ),
                unsafe sq != MAP_FAILED
            else {
                throw .setup(.posix(errno))
            }

            let cq: UnsafeMutableRawPointer
            let cqMmapSz: Int
            if isSingleMmap {
                cq = sq
                cqMmapSz = 0
            } else {
                cqMmapSz = cqRingSz
                guard
                    let cqPtr = unsafe mmap(
                        nil,
                        cqRingSz,
                        PROT_READ | PROT_WRITE,
                        MAP_SHARED | MAP_POPULATE,
                        fd,
                        Int(ISO_9945.Kernel.IO.Uring.Mmap.Offset.cqRing)
                    ),
                    unsafe cqPtr != MAP_FAILED
                else {
                    unsafe munmap(sq, sqMmapSz)
                    throw .setup(.posix(errno))
                }
                cq = cqPtr
            }

            guard
                let sqe = unsafe mmap(
                    nil,
                    sqeSz,
                    PROT_READ | PROT_WRITE,
                    MAP_SHARED | MAP_POPULATE,
                    fd,
                    Int(ISO_9945.Kernel.IO.Uring.Mmap.Offset.sqes)
                ),
                unsafe sqe != MAP_FAILED
            else {
                unsafe munmap(sq, sqMmapSz)
                if !isSingleMmap { unsafe munmap(cq, cqMmapSz) }
                throw .setup(.posix(errno))
            }

            unsafe self.init(
                ringDescriptor: consume descriptor,
                sqHead: sq.advanced(by: params.sqOff.head.vector.rawValue).assumingMemoryBound(
                    to: UInt32.self
                ),
                sqTail: sq.advanced(by: params.sqOff.tail.vector.rawValue).assumingMemoryBound(
                    to: UInt32.self
                ),
                sqMask: Submission.Queue.Mask(
                    rawValue: sq.load(
                        fromByteOffset: params.sqOff.ringMask.vector.rawValue,
                        as: UInt32.self
                    )
                ),
                sqEntries: params.sqEntries,
                sqArray: sq.advanced(by: params.sqOff.array.vector.rawValue).assumingMemoryBound(
                    to: UInt32.self
                ),
                sqes: sqe.assumingMemoryBound(
                    to: ISO_9945.Kernel.IO.Uring.Submission.Queue.Entry.self
                ),
                cqHead: cq.advanced(by: params.cqOff.head.vector.rawValue).assumingMemoryBound(
                    to: UInt32.self
                ),
                cqTail: cq.advanced(by: params.cqOff.tail.vector.rawValue).assumingMemoryBound(
                    to: UInt32.self
                ),
                cqMask: Completion.Queue.Mask(
                    rawValue: cq.load(
                        fromByteOffset: params.cqOff.ringMask.vector.rawValue,
                        as: UInt32.self
                    )
                ),
                cqes: UnsafePointer(
                    cq.advanced(by: params.cqOff.cqes.vector.rawValue)
                        .assumingMemoryBound(
                            to: ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry.self
                        )
                ),
                singleMmap: isSingleMmap,
                sqRingAddr: unsafe Memory.Memory.Address(sq),
                sqRingSize: ISO_9945.Kernel.File.Size(sqMmapSz),
                cqRingAddr: unsafe Memory.Memory.Address(cq),
                cqRingSize: ISO_9945.Kernel.File.Size(cqMmapSz),
                sqeAddr: unsafe Memory.Memory.Address(sqe),
                sqeSize: ISO_9945.Kernel.File.Size(sqeSz)
            )
        }
    }

    extension ISO_9945.Kernel.IO.Uring {

        public var next: Slot {
            mutating _read {
                let slot = sqMask.slot(for: sqeTail)
                let ptr = unsafe sqes.advanced(by: slot)
                yield unsafe Slot(ptr)
            }
        }

        public var hasCapacity: Bool {
            mutating get {
                let head = unsafe CPU.Atomic.load(sqHead, ordering: .acquiring)
                return sqEntries.underlying.rawValue > UInt(sqeTail &- head)
            }
        }

        public mutating func advance() {
            sqeTail &+= 1
        }

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

            unsafe CPU.Atomic.store(sqTail, localTail, ordering: .releasing)

            return Submission.Count(_unchecked: Cardinal(UInt(flushed)))
        }

        public var pending: Submission.Count {
            Submission.Count(_unchecked: Cardinal(UInt(sqeTail &- sqeHead)))
        }
    }

    extension ISO_9945.Kernel.IO.Uring {

        public mutating func drain(
            limit: Completion.Count,
            _ visitor: (Completion.Queue.Entry) -> Void
        ) -> Completion.Count {

            var head = unsafe cqHead.pointee
            let tail = unsafe CPU.Atomic.load(cqTail, ordering: .acquiring)
            let maxCount = Int(bitPattern: limit)
            var count = 0

            while head != tail, count < maxCount {
                let slot = cqMask.slot(for: head)
                unsafe visitor(cqes[slot])
                head &+= 1
                count += 1
            }

            unsafe CPU.Atomic.store(cqHead, head, ordering: .releasing)
            return Completion.Count(_unchecked: Cardinal(UInt(count)))
        }

        public var completionsAvailable: Completion.Count {
            let tail = unsafe CPU.Atomic.load(cqTail, ordering: .acquiring)
            let head = unsafe cqHead.pointee
            return Completion.Count(_unchecked: Cardinal(UInt(tail &- head)))
        }
    }

#endif
