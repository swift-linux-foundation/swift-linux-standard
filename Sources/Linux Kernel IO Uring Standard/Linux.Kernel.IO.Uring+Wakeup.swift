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
    @_spi(Syscall) public import Kernel_IO_Primitives
    @_spi(Syscall) public import Error_Primitives
    @_spi(Syscall) public import Kernel_Primitives_Core
    @_spi(Syscall) public import Kernel_Event_Primitives
    @_spi(Syscall) public import Linux_Kernel_Event_Standard

    // MARK: - createWakeup

    extension Kernel.IO.Uring {
        /// Create an eventfd registered with this io_uring for completion notification.
        ///
        /// Encapsulates:
        /// 1. eventfd creation (cloexec + nonblock)
        /// 2. io_uring registration (eventfd signals completions)
        /// 3. Wakeup channel construction (fire-and-forget signal closure)
        ///
        /// All raw fd handling is L1-local. The caller sees only typed values.
        ///
        /// - Returns: A ``Wakeup/Result`` containing the wakeup channel and eventfd.
        /// - Throws: ``Wakeup/Error`` on eventfd creation or registration failure.
        public func createWakeup() throws(Wakeup.Error) -> Wakeup.Result {
            // 1. Create eventfd
            let eventfd = try Self.createEventfd()

            // 2. Register with io_uring
            do throws(Kernel.IO.Uring.Error) {
                try self.register(eventfd: eventfd.descriptor)
            } catch {
                throw .register(error.code)
            }

            // 3. Build wakeup channel
            // Raw fd extracted for @Sendable closure capture —
            // ~Copyable Kernel.Event.Descriptor cannot be captured.
            let rawEfd = eventfd.descriptor._rawValue
            let channel = Kernel.Wakeup.Channel {
                Kernel.Event.Descriptor.signal(rawDescriptor: rawEfd)
            }

            return Wakeup.Result(
                channel: channel,
                eventfd: consume eventfd
            )
        }

        /// Create eventfd — helper avoids deferred ~Copyable init in typed throws.
        ///
        /// The eventfd is BLOCKING (no `EFD_NONBLOCK`) because
        /// ``Kernel/Completion/Notification/wait()`` does a blocking 8-byte
        /// read to sleep until the kernel signals a completion. A
        /// non-blocking eventfd would make the read return `EAGAIN`
        /// immediately, causing the completion Loop's run loop to hot-spin
        /// (~10k iterations/sec per Loop thread). `CLOEXEC` is retained
        /// so child processes don't inherit the eventfd.
        private static func createEventfd() throws(Wakeup.Error) -> Kernel.Event.Descriptor {
            do throws(Kernel.Event.Descriptor.Error) {
                return try Kernel.Event.Descriptor.create(flags: .cloexec)
            } catch {
                switch error {
                case .create(let code): throw .eventfd(code)
                case .read, .write, .wouldBlock:
                    throw .eventfd(.POSIX.EINVAL)
                }
            }
        }
    }

    // MARK: - Error code extraction

    extension Kernel.IO.Uring.Error {
        /// Extract the platform error code from any io_uring error case.
        var code: Error_Primitives.Error.Code {
            switch self {
            case .setup(let code): code
            case .enter(let code): code
            case .register(let code): code
            case .interrupted: .POSIX.EINTR
            }
        }
    }

#endif
