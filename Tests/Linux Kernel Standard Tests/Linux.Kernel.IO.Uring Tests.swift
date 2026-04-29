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
    import Kernel_Primitives_Test_Support
    import Kernel_Primitives_Core
    import Kernel_IO_Primitives
    import Kernel_Descriptor_Primitives
    import Error_Primitives
    import Kernel_File_Primitives
    import Memory_Primitives
    @testable import Linux_Kernel_IO_Uring_Standard

    #if canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring {
        enum Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
            @Suite struct Integration {}
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
                    entries: Kernel.IO.Uring.Submission.Count(__unchecked: (), Cardinal(0)),
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
                entries: Kernel.IO.Uring.Submission.Count(__unchecked: (), Cardinal(4)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            // Submit a NOP through the V6 Slot coroutine chain
            let nopData: Kernel.IO.Uring.Operation.Data = 0xCAFE_BABE

            ring.next.entry.nop(data: nopData)
            ring.advance()

            let flushed = ring.flush()
            #expect(flushed.rawValue.rawValue > 0)

            // Enter: submit 1, wait for 1 completion
            let submitted = try ring.enter(
                toSubmit: flushed,
                minComplete: 1,
                flags: .getEvents
            )
            #expect(submitted.rawValue.rawValue > 0)

            // Drain the CQE and verify the operation data round-tripped
            var receivedData: Kernel.IO.Uring.Operation.Data = 0
            var receivedResult: Int32 = -1

            let drained = ring.drain(
                limit: 16
            ) { cqe in
                receivedData = cqe.data
                receivedResult = cqe.res
            }
            #expect(drained.rawValue.rawValue == 1)
            #expect(receivedData == nopData)
            #expect(receivedResult == 0)  // NOP always succeeds with res=0
        }

        /// Submits multiple NOPs in a batch to verify the Slot coroutine
        /// correctly handles sequential next/advance cycles.
        @Test
        func `batch nop submission via Slot`() throws {
            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(__unchecked: (), Cardinal(8)),
                params: &params
            )
            var ring = try Kernel.IO.Uring(descriptor: consume fd, params: params)

            // Submit 4 NOPs with distinct data values
            let count = 4
            for i in 0..<count {
                let data = Kernel.IO.Uring.Operation.Data(__unchecked: (), UInt64(0x100 + i))
                ring.next.entry.nop(data: data)
                ring.advance()
            }

            let flushed = ring.flush()
            #expect(flushed.rawValue.rawValue == UInt(count))

            _ = try ring.enter(
                toSubmit: flushed,
                minComplete: Kernel.IO.Uring.Completion.Count(__unchecked: (), Cardinal(UInt(count))),
                flags: .getEvents
            )

            // Drain all completions and collect data values
            var received = Set<UInt64>()
            let drained = ring.drain(
                limit: 16
            ) { cqe in
                received.insert(cqe.data.rawValue)
                #expect(cqe.isSuccess)  // all NOPs succeed
            }
            #expect(drained.rawValue.rawValue == UInt(count))
            #expect(received == [0x100, 0x101, 0x102, 0x103])
        }

        /// Verifies that multiple accesses to ring.next without advance()
        /// hit the same slot — the Slot coroutine design invariant.
        @Test
        func `repeated next access without advance writes same slot`() throws {
            var params = Kernel.IO.Uring.Params()
            let fd = try Kernel.IO.Uring.setup(
                entries: Kernel.IO.Uring.Submission.Count(__unchecked: (), Cardinal(4)),
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
                entries: Kernel.IO.Uring.Submission.Count(__unchecked: (), Cardinal(4)),
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
