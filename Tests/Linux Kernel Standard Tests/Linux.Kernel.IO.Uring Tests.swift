#if os(Linux)
    import Testing
    import Error_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    import ISO_9945_Core
    private typealias Kernel = ISO_9945.Kernel

    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    #if canImport(Linux_Kernel_Shims)
        import Linux_Kernel_Shims
    #endif

    private func probeIOUringSupported() throws -> Bool {
        var params = Kernel.IO.Uring.Params()
        do {
            let descriptor = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(1)),
                params: &params
            )

            consume descriptor
            return true
        } catch let error {
            guard case Kernel.IO.Uring.Error.setup(let code) = error else {
                throw error
            }
            guard code == .posix(EPERM) || code == .posix(ENOSYS) else {
                throw error
            }
            return false
        }
    }

    extension Kernel.IO.Uring {
        enum Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
            @Suite(.enabled(if: try probeIOUringSupported())) struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension Kernel.IO.Uring.Test.Unit {
        @Test
        func `setup with invalid entries throws`() throws {
            var params = Kernel.IO.Uring.Params()

            #expect(throws: Kernel.IO.Uring.Error.self) {
                _ = try Kernel.IO.Uring.setup(
                    entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(0)),
                    params: &params
                )
            }
        }
    }

    extension Kernel.IO.Uring.Test.Integration {

        @Test
        func `nop round-trip through Slot coroutine`() throws {

            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(4)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            let nopData: Kernel.IO.Uring.Operation.Data = 0xCAFE_BABE

            ring.next.entry.nop(data: nopData)
            ring.advance()

            let flushed = ring.flush()
            #expect(flushed.underlying.rawValue > 0)

            let submitted = try ring.enter(
                toSubmit: flushed,
                minComplete: 1,
                flags: .getEvents
            )
            #expect(submitted.underlying.rawValue > 0)

            var receivedData: Kernel.IO.Uring.Operation.Data = 0
            var receivedResult: Int32 = -1

            let drained = ring.drain(
                limit: 16
            ) { cqe in
                receivedData = cqe.data
                receivedResult = cqe.res
            }
            #expect(drained.underlying.rawValue == 1)
            #expect(receivedData == nopData)
            #expect(receivedResult == 0)
        }

        @Test
        func `batch nop submission via Slot`() throws {
            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(8)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            let count = 4
            for i in 0..<count {
                let data = Kernel.IO.Uring.Operation.Data(_unchecked: UInt64(0x100 + i))
                ring.next.entry.nop(data: data)
                ring.advance()
            }

            let flushed = ring.flush()
            #expect(flushed.underlying.rawValue == UInt(count))

            _ = try ring.enter(
                toSubmit: flushed,
                minComplete: Kernel.IO.Uring.Completion.Count(_unchecked: Cardinal(UInt(count))),
                flags: .getEvents
            )

            var received = Set<UInt64>()
            let drained = ring.drain(
                limit: 16
            ) { cqe in
                received.insert(cqe.data.underlying)
                #expect(cqe.isSuccess)
            }
            #expect(drained.underlying.rawValue == UInt(count))
            #expect(received == [0x100, 0x101, 0x102, 0x103])
        }

        @Test
        func `repeated next access without advance writes same slot`() throws {
            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(4)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            let firstData: Kernel.IO.Uring.Operation.Data = 0xAAAA
            let secondData: Kernel.IO.Uring.Operation.Data = 0xBBBB

            ring.next.entry.nop(data: firstData)

            ring.next.entry.nop(data: secondData)
            ring.advance()

            let flushed = ring.flush()
            _ = try ring.enter(
                toSubmit: flushed,
                minComplete: 1,
                flags: .getEvents
            )

            var receivedData: Kernel.IO.Uring.Operation.Data = 0
            _ = ring.drain(
                limit: 16
            ) { cqe in
                receivedData = cqe.data
            }

            #expect(receivedData == secondData)
        }

        @Test
        func `Slot.entry _modify writes through to mmap'd memory`() throws {
            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(4)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            let data: Kernel.IO.Uring.Operation.Data = 0xDEAD_BEEF
            ring.next.entry.nop(data: data)

            #expect(ring.next.entry.opcode == .nop)
            #expect(ring.next.entry.data == data)

            ring.advance()
            let flushed = ring.flush()
            _ = try ring.enter(
                toSubmit: flushed,
                minComplete: 1,
                flags: .getEvents
            )

            var receivedData: Kernel.IO.Uring.Operation.Data = 0
            _ = ring.drain(
                limit: 16
            ) { cqe in
                receivedData = cqe.data
            }
            #expect(receivedData == data)
        }
    }

#endif
