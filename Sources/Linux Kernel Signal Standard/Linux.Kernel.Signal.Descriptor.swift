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

    @_spi(Syscall) public import ISO_9945_Core
    @_spi(Syscall) public import ISO_9945_Kernel_Signal
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension ISO_9945.Kernel.Signal {
        /// Signal file descriptor — a Linux primitive (`signalfd(2)`) that
        /// delivers signals as readable events on a file descriptor instead
        /// of via signal handlers.
        ///
        /// `~Copyable`: single ownership, consumed on `close()` or deinit.
        ///
        /// `Sendable`: the fd value is safe to transfer between threads.
        ///
        /// The kernel queues signals matching the fd's mask; reading drains
        /// queued `signalfd_siginfo` records. Common uses: handling signals
        /// synchronously inside `poll(2)`/`epoll(2)`/`io_uring` event loops
        /// without the reentrancy hazards of POSIX signal handlers.
        ///
        /// Available since Linux 2.6.22.
        public struct Descriptor: ~Copyable, Sendable {
            /// The underlying kernel file descriptor.
            @_spi(Syscall)
            public let descriptor: ISO_9945.Kernel.Descriptor

            /// Creates a signal descriptor wrapping the given fd.
            @_spi(Syscall)
            @inlinable
            public init(descriptor: consuming ISO_9945.Kernel.Descriptor) {
                self.descriptor = descriptor
            }
        }
    }

    // MARK: - Factory

    extension ISO_9945.Kernel.Signal.Descriptor {
        /// Creates a new signal descriptor that delivers the given mask.
        ///
        /// The signals named by `mask` MUST be blocked in the calling thread
        /// (and ideally process-wide) via `pthread_sigmask` / `sigprocmask`,
        /// otherwise they are still delivered to the default handler.
        ///
        /// - Parameters:
        ///   - mask: Signal set the descriptor should deliver, a populated
        ///     ``ISO_9945/Kernel/Signal/Set``.
        ///   - flags: Creation flags (`SFD_CLOEXEC`, `SFD_NONBLOCK`).
        ///
        /// - Returns: An owned signal descriptor.
        ///
        /// - Throws: ``Error/create(_:)`` on failure.
        public static func create(
            mask: borrowing ISO_9945.Kernel.Signal.Set,
            flags: Int32? = nil
        ) throws(ISO_9945.Kernel.Signal.Descriptor.Error) -> ISO_9945.Kernel.Signal.Descriptor {
            // `SFD_CLOEXEC` is imported `internal` from Glibc and so cannot appear
            // in a default-argument value; resolve it in the body instead.
            let resolvedFlags = flags ?? Int32(SFD_CLOEXEC)
            // The set's `sigset_t` is owned by iso-9945 (kept off its public API
            // per PLAT-ARCH-005a); reach it via the opaque raw-pointer bridge and
            // bind to the platform `sigset_t` here, inside linux-standard's own
            // platform-C scope, to hand it to the Linux-only `signalfd(2)`.
            let fd = unsafe mask.withUnsafeRawPointer { raw in
                unsafe signalfd(-1, raw.assumingMemoryBound(to: sigset_t.self), resolvedFlags)
            }
            guard fd >= 0 else {
                throw .create(.posix(errno))
            }
            return ISO_9945.Kernel.Signal.Descriptor(descriptor: ISO_9945.Kernel.Descriptor(_rawValue: fd))
        }
    }

    // MARK: - Consuming Extraction

    extension ISO_9945.Kernel.Descriptor {
        /// Extract the kernel descriptor from a signal descriptor, consuming it.
        ///
        /// The caller takes ownership of the returned descriptor — its deinit
        /// closes the fd. The signal descriptor is fully consumed.
        ///
        /// Enables cross-platform code that needs a ``Kernel/Descriptor``
        /// rather than the Linux-specific ``Kernel/Signal/Descriptor``.
        public init(_ signalDescriptor: consuming ISO_9945.Kernel.Signal.Descriptor) {
            self = signalDescriptor.descriptor
        }
    }

    // MARK: - Lifecycle

    extension ISO_9945.Kernel.Signal.Descriptor {
        /// Explicitly closes the signal descriptor.
        ///
        /// After this call, the descriptor is invalid. If not called,
        /// deinit closes the fd automatically (safety net).
        public consuming func close() {
            _ = consume self
        }
    }

#endif
