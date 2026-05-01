// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-linux-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

public import Error_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if canImport(CLinuxKernelShim)
    internal import CLinuxKernelShim
#endif

extension ISO_9945.Kernel.Timer {
    /// Timer file descriptor — a Linux primitive (`timerfd_create(2)`)
    /// that delivers timer expirations as readable events on a file
    /// descriptor.
    ///
    /// `~Copyable`: single ownership, consumed on `close()` or deinit.
    /// `Sendable`: the fd value is safe to transfer between threads.
    ///
    /// Each expiration increments an internal `UInt64` counter; reading
    /// drains and returns the count. Common uses: integrating periodic
    /// timers into `poll(2)`/`epoll(2)`/`io_uring` event loops without
    /// signal-handler complexity.
    ///
    /// Available since Linux 2.6.25.
    public struct Descriptor: ~Copyable, Sendable {
        /// The underlying kernel file descriptor.
        @_spi(Syscall)
        public let descriptor: ISO_9945.Kernel.Descriptor

        /// Creates a timer descriptor wrapping the given fd.
        @_spi(Syscall)
        @inlinable
        public init(descriptor: consuming ISO_9945.Kernel.Descriptor) {
            self.descriptor = descriptor
        }
    }
}

// MARK: - Factory

extension ISO_9945.Kernel.Timer.Descriptor {
    /// Creates a new timer descriptor.
    ///
    /// - Parameters:
    ///   - clockId: The clock the timer reads from (`CLOCK_MONOTONIC`,
    ///     `CLOCK_REALTIME`, etc.). Defaults to `CLOCK_MONOTONIC`.
    ///   - flags: Creation flags (`TFD_CLOEXEC`, `TFD_NONBLOCK`).
    /// - Returns: An owned timer descriptor.
    /// - Throws: ``Error/create(_:)`` on failure.
    public static func create(
        clockId: Int32 = CLOCK_MONOTONIC,
        flags: Int32 = TFD_CLOEXEC
    ) throws(ISO_9945.Kernel.Timer.Descriptor.Error) -> ISO_9945.Kernel.Timer.Descriptor {
        let fd = unsafe timerfd_create(clockId, flags)
        guard fd >= 0 else {
            throw .create(.posix(errno))
        }
        return ISO_9945.Kernel.Timer.Descriptor(descriptor: ISO_9945.Kernel.Descriptor(_rawValue: fd))
    }
}

// MARK: - Consuming Extraction

extension ISO_9945.Kernel.Descriptor {
    /// Extract the kernel descriptor from a timer descriptor, consuming it.
    ///
    /// The caller takes ownership of the returned descriptor — its deinit
    /// closes the fd. The timer descriptor is fully consumed.
    ///
    /// Enables cross-platform code that needs a ``Kernel/Descriptor``
    /// rather than the Linux-specific ``Kernel/Timer/Descriptor``.
    public init(_ timerDescriptor: consuming ISO_9945.Kernel.Timer.Descriptor) {
        self = timerDescriptor.descriptor
    }
}

// MARK: - Lifecycle

extension ISO_9945.Kernel.Timer.Descriptor {
    /// Explicitly closes the timer descriptor.
    ///
    /// After this call, the descriptor is invalid. If not called,
    /// deinit closes the fd automatically (safety net).
    public consuming func close() {
        _ = consume self
    }
}

#endif
