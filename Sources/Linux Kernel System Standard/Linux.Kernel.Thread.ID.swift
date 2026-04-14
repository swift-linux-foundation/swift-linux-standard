// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-standard open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-linux-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux) || os(Android) || os(OpenBSD)

@_spi(Syscall) public import Kernel_Thread_Primitives
internal import CLinuxKernelShim

#if canImport(Glibc)
internal import Glibc
#elseif canImport(Musl)
internal import Musl
#elseif canImport(Bionic)
internal import Bionic
#endif

extension Kernel.Thread {
    /// Opaque OS thread identifier on Linux-family kernels.
    ///
    /// The raw value is the kernel TID (thread ID) as returned by the
    /// `gettid()` syscall. It's the identifier used by `/proc/<pid>/task/`,
    /// perf, and debuggers. Though typed as `pid_t`, thread TIDs and process
    /// PIDs occupy the same namespace in the Linux kernel.
    ///
    /// Not portable across processes or platforms. Within a single process,
    /// two `ID` values compare equal iff they refer to the same OS thread.
    public struct ID: Hashable, Sendable, RawRepresentable, CustomStringConvertible {
        /// The kernel thread ID. On Linux-family, `pid_t` is typedef'd to
        /// `Int32`; we expose `Int32` directly to avoid leaking the platform
        /// typedef into the public API.
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public var description: String { "tid(\(rawValue))" }
    }
}

extension Kernel.Thread.ID {
    /// The ID of the calling thread.
    public static var current: Self {
        .init(rawValue: Int32(unsafe swift_gettid()))
    }
}

#endif
