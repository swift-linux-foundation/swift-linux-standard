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

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if canImport(CLinuxShim)
    internal import CLinuxShim
#endif

extension Kernel.Event {
    /// Event file descriptor — a Linux signaling primitive (`eventfd(2)`).
    ///
    /// `~Copyable`: single ownership, consumed on `close()` or deinit.
    /// `Sendable`: the fd value is safe to transfer between threads.
    ///
    /// Maintains an internal uint64 counter. Writing adds to the counter;
    /// reading drains it (or decrements by 1 in semaphore mode).
    /// Common uses: waking poll/epoll loops, inter-thread signaling,
    /// completion counters.
    public struct Descriptor: ~Copyable, Sendable {
        /// The underlying kernel file descriptor.
        @_spi(Syscall)
        public let descriptor: Kernel.Descriptor

        /// Creates an event descriptor wrapping the given fd.
        @_spi(Syscall)
        @inlinable
        public init(descriptor: consuming Kernel.Descriptor) {
            self.descriptor = descriptor
        }
    }
}

// MARK: - Factory

extension Kernel.Event.Descriptor {
    /// Creates a new event descriptor.
    ///
    /// - Parameters:
    ///   - value: Initial counter value (default 0).
    ///   - flags: Creation flags (default `.cloexec`).
    /// - Returns: An owned event descriptor.
    /// - Throws: ``Error/create(_:)`` on failure.
    public static func create(
        value: UInt32 = 0,
        flags: Flags = .cloexec
    ) throws(Kernel.Event.Descriptor.Error) -> Kernel.Event.Descriptor {
        let fd = eventfd(value, flags.rawValue)
        guard fd >= 0 else {
            throw .create(.posix(errno))
        }
        return Kernel.Event.Descriptor(descriptor: Kernel.Descriptor(_rawValue: fd))
    }
}

// MARK: - Operations

extension Kernel.Event.Descriptor {
    /// Reads the counter value.
    ///
    /// In default mode, returns the current counter and resets it to zero.
    /// In semaphore mode (`.semaphore` flag), returns 1 and decrements by 1.
    ///
    /// Blocks if the counter is zero and the fd is blocking.
    /// Throws `.wouldBlock` if the counter is zero and the fd is non-blocking.
    public mutating func read() throws(Kernel.Event.Descriptor.Error) -> UInt64 {
        var value: UInt64 = 0
        let result = unsafe read(descriptor._rawValue, &value, MemoryLayout<UInt64>.size)
        guard result == MemoryLayout<UInt64>.size else {
            let code = Kernel.Error.Code.posix(errno)
            if code == .POSIX.EAGAIN || code == .POSIX.EWOULDBLOCK {
                throw .wouldBlock
            }
            throw .read(code)
        }
        return value
    }

    /// Writes a value to the counter (adds to it).
    ///
    /// The maximum value is `UInt64.max - 1`. If adding `value` would
    /// overflow, the write blocks (blocking mode) or throws `.wouldBlock`
    /// (non-blocking mode).
    public mutating func write(_ value: UInt64) throws(Kernel.Event.Descriptor.Error) {
        var val = value
        let result = unsafe write(descriptor._rawValue, &val, MemoryLayout<UInt64>.size)
        guard result == MemoryLayout<UInt64>.size else {
            let code = Kernel.Error.Code.posix(errno)
            if code == .POSIX.EAGAIN || code == .POSIX.EWOULDBLOCK {
                throw .wouldBlock
            }
            throw .write(code)
        }
    }

    /// Fire-and-forget signal: writes 1 to the counter.
    ///
    /// Suppresses EAGAIN (counter near max, benign coalescing) and
    /// EBADF (fd closed during shutdown, benign teardown race).
    public func signal() {
        Kernel.Event.Descriptor.signal(rawDescriptor: descriptor._rawValue)
    }

    /// Fire-and-forget signal using a raw file descriptor.
    ///
    /// For use in `Sendable` closures that cannot capture `~Copyable`
    /// `Kernel.Event.Descriptor`.
    ///
    /// Suppresses EAGAIN and EBADF.
    @_spi(Syscall)
    public static func signal(rawDescriptor fd: Int32) {
        var val: UInt64 = 1
        let result = unsafe write(fd, &val, MemoryLayout<UInt64>.size)
        if result < 0 {
            let code = Kernel.Error.Code.posix(errno)
            if code == .POSIX.EAGAIN || code == .POSIX.EWOULDBLOCK || code == .POSIX.EBADF {
                // Benign: counter full (coalesced wakeup) or fd closed during shutdown
            } else {
                assertionFailure("eventfd signal failed: \(code)")
            }
        }
    }
}

// MARK: - Lifecycle

extension Kernel.Event.Descriptor {
    /// Explicitly closes the event descriptor.
    ///
    /// After this call, the descriptor is invalid. If not called,
    /// deinit closes the fd automatically (safety net).
    public consuming func close() {
        _ = consume self
    }
}

#endif
