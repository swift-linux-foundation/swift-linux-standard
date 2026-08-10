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

    // MARK: - Capability Probe

    /// Whether the current environment permits `io_uring_setup(2)`.
    ///
    /// CI containers commonly deny io_uring via seccomp/capability
    /// restriction (`EPERM`) or run kernels without io_uring support
    /// (`ENOSYS`); neither is a code defect. Probes with a minimal,
    /// immediately-torn-down ring rather than assuming availability —
    /// per the coordinator ruling in
    /// swift-linux-foundation/swift-linux-standard#5 (comment 5135876054).
    ///
    /// Any other `setup` failure mode is a genuine bug, not an environment
    /// capability gap, and is left to propagate so the suite fails loudly
    /// instead of silently skipping.
    private func probeIOUringSupported() throws -> Bool {
        var params = Kernel.IO.Uring.Params()
        do {
            let descriptor = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(1)),
                params: &params
            )
            // Descriptor is ~Copyable; consuming it here runs its deinit,
            // which closes the fd — no explicit close needed for the probe.
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

    // MARK: - Unit Tests

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

    // MARK: - Integration Tests

    extension Kernel.IO.Uring.Test.Integration {

        /// Full V6 call chain: ring.next.entry → mutating prepare → advance → flush → enter → drain.
        ///
        /// Submits a NOP via the ~Escapable Slot coroutine and verifies the kernel
        /// returns the correct operation data in the CQE.
        @Test
        func `nop round-trip through Slot coroutine`() throws {
            // Setup ring with 4 entries
            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(4)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            // Submit a NOP through the V6 Slot coroutine chain
            let nopData: Kernel.IO.Uring.Operation.Data = 0xCAFE_BABE

            ring.next.entry.nop(data: nopData)
            ring.advance()

            let flushed = ring.flush()
            #expect(flushed.underlying.rawValue > 0)

            // Enter: submit 1, wait for 1 completion
            let submitted = try ring.enter(
                toSubmit: flushed,
                minComplete: 1,
                flags: .getEvents
            )
            #expect(submitted.underlying.rawValue > 0)

            // Drain the CQE and verify the operation data round-tripped
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
            #expect(receivedResult == 0)  // NOP always succeeds with res=0
        }

        /// Submits multiple NOPs in a batch to verify the Slot coroutine
        /// correctly handles sequential next/advance cycles.
        @Test
        func `batch nop submission via Slot`() throws {
            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(8)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            // Submit 4 NOPs with distinct data values
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

            // Drain all completions and collect data values
            var received = Set<UInt64>()
            let drained = ring.drain(
                limit: 16
            ) { cqe in
                received.insert(cqe.data.underlying)
                #expect(cqe.isSuccess)  // all NOPs succeed
            }
            #expect(drained.underlying.rawValue == UInt(count))
            #expect(received == [0x100, 0x101, 0x102, 0x103])
        }

        /// Verifies that multiple accesses to ring.next without advance()
        /// hit the same slot — the Slot coroutine design invariant.
        @Test
        func `repeated next access without advance writes same slot`() throws {
            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(4)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            // Write to the same slot twice — second write overwrites first
            let firstData: Kernel.IO.Uring.Operation.Data = 0xAAAA
            let secondData: Kernel.IO.Uring.Operation.Data = 0xBBBB

            ring.next.entry.nop(data: firstData)
            // No advance() — next access hits the same slot
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
            // Second write wins — the slot was overwritten
            #expect(receivedData == secondData)
        }

        /// Verifies that the nonmutating _modify on Slot.entry correctly
        /// writes through the pointer to mmap'd SQE memory.
        @Test
        func `Slot.entry _modify writes through to mmap'd memory`() throws {
            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(_unchecked: Cardinal(4)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            // Use the Slot coroutine to set data, then read back through
            // the same slot to verify write-through
            let data: Kernel.IO.Uring.Operation.Data = 0xDEAD_BEEF
            ring.next.entry.nop(data: data)

            // Read back via same slot (no advance) — should see what we wrote
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
