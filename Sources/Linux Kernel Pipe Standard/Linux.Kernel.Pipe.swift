// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives

#if canImport(Glibc)
    internal import Glibc
    internal import CLinuxKernelShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux pipe2 Implementation — raw fd SPI

extension Kernel.Pipe {
    /// Creates a pipe with the specified flags (Linux) — raw fd SPI.
    ///
    /// Spec-literal: returns the raw `Int32` fds atomically. The L3-policy
    /// typed-descriptor convenience (out-param `inout Kernel.Descriptor`
    /// shape) AND the `Kernel.Descriptor.Validity.Error → .handle(...)`
    /// normalization both live at swift-linux per [PLAT-ARCH-005] /
    /// [PLAT-ARCH-008e]. L2 raw stays platform-error-only because
    /// `Validity.Error.init?(code:)` is an iso-9945 extension and the
    /// Linux Kernel Pipe Standard target does not depend on iso-9945.
    ///
    /// Uses pipe2(2) which atomically sets flags on both descriptors,
    /// avoiding race conditions between pipe() and fcntl(). Returns the
    /// pair of newly-created fds — § 5.6 handle-returning bifurcation
    /// generalized to a pair.
    ///
    /// - Parameter flags: Flags to apply to the pipe descriptors.
    /// - Returns: A tuple `(read, write)` of raw fds for the read end and
    ///   write end of the pipe.
    /// - Throws: `Kernel.Pipe.Error.platform` on failure. L3-policy refines
    ///   to `.handle(...)` for `Kernel.Descriptor.Validity.Error` codes.
    @_spi(Syscall)
    public static func pipe2(
        flags: Options
    ) throws(Error) -> (read: Int32, write: Int32) {
        var fds: (Int32, Int32) = (0, 0)

        let result = withUnsafeMutablePointer(to: &fds) { ptr in
            ptr.withMemoryRebound(to: Int32.self, capacity: 2) { fdPtr in
                swift_pipe2(fdPtr, flags.rawValue)
            }
        }

        guard result == 0 else {
            // Validity.Error.init?(code:) is an iso-9945 extension; this target
            // does not depend on iso-9945. Refining to .handle(...) for
            // descriptor-validity codes happens at swift-linux L3-policy, where
            // the iso-9945 extension is in scope.
            throw .platform(Kernel.Error(code: .posix(errno)))
        }

        return (read: fds.0, write: fds.1)
    }

    /// Options for pipe creation (Linux).
    public struct Options: OptionSet, Sendable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Set the close-on-exec flag on the new file descriptors.
        public static let closeOnExec = Self(rawValue: O_CLOEXEC)

        /// Set the non-blocking flag on the new file descriptors.
        public static let nonBlock = Self(rawValue: O_NONBLOCK)

        /// Create a direct I/O pipe (Linux 3.4+).
        public static let direct = Self(rawValue: O_DIRECT)
    }
}

#endif
