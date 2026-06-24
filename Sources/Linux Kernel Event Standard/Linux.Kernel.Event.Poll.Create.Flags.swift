// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

public import ISO_9945_Core
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension ISO_9945.Kernel.Event.Poll.Create {
        /// Flags for creating an epoll instance.
        ///
        /// Used with `epoll_create1` to control the behavior of the
        /// newly created epoll file descriptor.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Create epoll with close-on-exec (recommended)
        /// let epfd = try ISO_9945.Kernel.Event.Poll.create(flags: .cloexec)
        /// defer { try? ISO_9945.Kernel.Close.close(epfd) }
        ///
        /// // Add descriptors and poll for events...
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Event/Poll``
        /// - ``Kernel/Event/Poll/Operation``
        public struct Flags: OptionSet, Sendable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.Event.Poll.Create.Flags {
        /// No flags.
        public static let none = Self(rawValue: 0)

        /// Sets the close-on-exec flag on the epoll file descriptor.
        ///
        /// Prevents the epoll fd from leaking to child processes created
        /// with `exec()`. Recommended for most applications.
        ///
        /// - Linux: `EPOLL_CLOEXEC`
        public static let cloexec = Self(rawValue: Int32(EPOLL_CLOEXEC))
    }

#endif
