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

extension ISO_9945.Kernel.Process {
    /// Process file descriptor — a Linux primitive (`pidfd_open(2)`) that
    /// references a process by file descriptor rather than PID.
    ///
    /// `~Copyable`: single ownership, consumed on `close()` or deinit.
    /// `Sendable`: the fd value is safe to transfer between threads.
    ///
    /// A pidfd refers to a specific process (not a PID that may be reused).
    /// Common uses: race-free signal delivery (`pidfd_send_signal(2)`),
    /// process readiness via `poll(2)`/`epoll(2)` (POLLIN on a pidfd
    /// indicates the referenced process has terminated), and
    /// `waitid(P_PIDFD, ...)`.
    ///
    /// Available since Linux 5.3.
    public struct Descriptor: ~Copyable, Sendable {
        /// The underlying kernel file descriptor.
        @_spi(Syscall)
        public let descriptor: ISO_9945.Kernel.Descriptor

        /// Creates a process descriptor wrapping the given fd.
        @_spi(Syscall)
        @inlinable
        public init(descriptor: consuming ISO_9945.Kernel.Descriptor) {
            self.descriptor = descriptor
        }
    }
}

// MARK: - Factory

extension ISO_9945.Kernel.Process.Descriptor {
    /// Creates a pidfd referring to the given process.
    ///
    /// - Parameters:
    ///   - pid: The target process ID.
    ///   - flags: Open flags. Currently must be 0; reserved for future
    ///     kernel extensions (the close-on-exec flag is implicit on
    ///     pidfds — they always carry FD_CLOEXEC).
    /// - Returns: An owned process descriptor.
    /// - Throws: ``Error/create(_:)`` on failure.
    public static func create(
        pid: ISO_9945.Kernel.Process.ID,
        flags: UInt32 = 0
    ) throws(ISO_9945.Kernel.Process.Descriptor.Error) -> ISO_9945.Kernel.Process.Descriptor {
        let fd = unsafe swift_pidfd_open(pid.rawValue, flags)
        guard fd >= 0 else {
            throw .create(.posix(errno))
        }
        return ISO_9945.Kernel.Process.Descriptor(descriptor: ISO_9945.Kernel.Descriptor(_rawValue: fd))
    }
}

// MARK: - Consuming Extraction

extension ISO_9945.Kernel.Descriptor {
    /// Extract the kernel descriptor from a process descriptor, consuming it.
    ///
    /// The caller takes ownership of the returned descriptor — its deinit
    /// closes the fd. The process descriptor is fully consumed.
    ///
    /// Enables cross-platform code that needs a ``Kernel/Descriptor``
    /// rather than the Linux-specific ``Kernel/Process/Descriptor``.
    public init(_ processDescriptor: consuming ISO_9945.Kernel.Process.Descriptor) {
        self = processDescriptor.descriptor
    }
}

// MARK: - Lifecycle

extension ISO_9945.Kernel.Process.Descriptor {
    /// Explicitly closes the process descriptor.
    ///
    /// After this call, the descriptor is invalid. If not called,
    /// deinit closes the fd automatically (safety net).
    public consuming func close() {
        _ = consume self
    }
}

#endif
