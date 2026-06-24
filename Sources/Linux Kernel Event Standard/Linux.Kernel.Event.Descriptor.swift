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

@_spi(Syscall) public import ISO_9945_Core
public import Error_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if canImport(CLinuxKernelShim)
    internal import CLinuxKernelShim
#endif

extension ISO_9945.Kernel.Event {
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
        public let descriptor: ISO_9945.Kernel.Descriptor

        /// Creates an event descriptor wrapping the given fd.
        @_spi(Syscall)
        @inlinable
        public init(descriptor: consuming ISO_9945.Kernel.Descriptor) {
            self.descriptor = descriptor
        }
    }
}

// MARK: - Factory

extension ISO_9945.Kernel.Event.Descriptor {
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
    ) throws(ISO_9945.Kernel.Event.Descriptor.Error) -> ISO_9945.Kernel.Event.Descriptor {
        let fd = eventfd(value, flags.rawValue)
        guard fd >= 0 else {
            throw .create(.posix(errno))
        }
        return ISO_9945.Kernel.Event.Descriptor(descriptor: ISO_9945.Kernel.Descriptor(_rawValue: fd))
    }
}

// MARK: - Operations

extension ISO_9945.Kernel.Event.Descriptor {
    /// Reads the counter value.
    ///
    /// In default mode, returns the current counter and resets it to zero.
    /// In semaphore mode (`.semaphore` flag), returns 1 and decrements by 1.
    ///
    /// Blocks if the counter is zero and the fd is blocking.
    /// Throws `.wouldBlock` if the counter is zero and the fd is non-blocking.
    public mutating func read() throws(ISO_9945.Kernel.Event.Descriptor.Error) -> UInt64 {
        var value: UInt64 = 0
        #if canImport(Glibc)
        let result = unsafe Glibc.read(descriptor._rawValue, &value, MemoryLayout<UInt64>.size)
        #elseif canImport(Musl)
        let result = unsafe Musl.read(descriptor._rawValue, &value, MemoryLayout<UInt64>.size)
        #endif
        guard result == MemoryLayout<UInt64>.size else {
            let code = Error_Primitives.Error.Code.posix(errno)
            if code == .posix(EAGAIN) || code == .posix(EWOULDBLOCK) {
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
    public mutating func write(_ value: UInt64) throws(ISO_9945.Kernel.Event.Descriptor.Error) {
        var val = value
        #if canImport(Glibc)
        let result = unsafe Glibc.write(descriptor._rawValue, &val, MemoryLayout<UInt64>.size)
        #elseif canImport(Musl)
        let result = unsafe Musl.write(descriptor._rawValue, &val, MemoryLayout<UInt64>.size)
        #endif
        guard result == MemoryLayout<UInt64>.size else {
            let code = Error_Primitives.Error.Code.posix(errno)
            if code == .posix(EAGAIN) || code == .posix(EWOULDBLOCK) {
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
        ISO_9945.Kernel.Event.Descriptor.signal(rawDescriptor: descriptor._rawValue)
    }

    /// Fire-and-forget signal using a raw file descriptor.
    ///
    /// For use in `Sendable` closures that cannot capture `~Copyable`
    /// `ISO_9945.Kernel.Event.Descriptor`.
    ///
    /// Suppresses EAGAIN and EBADF.
    package static func signal(rawDescriptor fd: Int32) {
        var val: UInt64 = 1
        #if canImport(Glibc)
        let result = unsafe Glibc.write(fd, &val, MemoryLayout<UInt64>.size)
        #elseif canImport(Musl)
        let result = unsafe Musl.write(fd, &val, MemoryLayout<UInt64>.size)
        #endif
        if result < 0 {
            let code = Error_Primitives.Error.Code.posix(errno)
            if code == .posix(EAGAIN) || code == .posix(EWOULDBLOCK) || code == .posix(EBADF) {
                // Benign: counter full (coalesced wakeup) or fd closed during shutdown
            } else {
                assertionFailure("eventfd signal failed: \(code)")
            }
        }
    }
}

// MARK: - Consuming Extraction

extension ISO_9945.Kernel.Descriptor {
    /// Extract the kernel descriptor from an event descriptor, consuming it.
    ///
    /// The caller takes ownership of the returned descriptor — its deinit
    /// closes the fd. The event descriptor is fully consumed.
    ///
    /// Enables cross-platform code that needs a ``Kernel/Descriptor``
    /// rather than the Linux-specific ``Kernel/Event/Descriptor``.
    public init(_ eventDescriptor: consuming ISO_9945.Kernel.Event.Descriptor) {
        self = eventDescriptor.descriptor
    }
}

// MARK: - Lifecycle

extension ISO_9945.Kernel.Event.Descriptor {
    /// Explicitly closes the event descriptor.
    ///
    /// After this call, the descriptor is invalid. If not called,
    /// deinit closes the fd automatically (safety net).
    public consuming func close() {
        _ = consume self
    }
}

#endif
