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
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives

#if canImport(Glibc)
    internal import Glibc
    internal import CLinuxKernelShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux pipe2 Implementation

extension Kernel.Pipe {
    /// Creates a pipe with the specified flags (Linux).
    ///
    /// Uses pipe2(2) which atomically sets flags on both descriptors,
    /// avoiding race conditions between pipe() and fcntl().
    ///
    /// - Parameter flags: Flags to apply to the pipe descriptors.
    /// - Parameters:
    ///   - flags: Flags to apply to the pipe descriptors.
    ///   - read: On return, the read end of the pipe.
    ///   - write: On return, the write end of the pipe.
    /// - Throws: `Kernel.Pipe.Error` on failure.
    public static func pipe2(
        flags: Options,
        read: inout Kernel.Descriptor,
        write: inout Kernel.Descriptor
    ) throws(Error) {
        var fds: (Int32, Int32) = (0, 0)

        let result = withUnsafeMutablePointer(to: &fds) { ptr in
            ptr.withMemoryRebound(to: Int32.self, capacity: 2) { fdPtr in
                swift_pipe2(fdPtr, flags.rawValue)
            }
        }

        guard result == 0 else {
            let code = Kernel.Error.Code.posix(errno)
            if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
                throw .handle(handleError)
            }
            throw .platform(Kernel.Error(code: code))
        }

        read = Kernel.Descriptor(_rawValue: fds.0)
        write = Kernel.Descriptor(_rawValue: fds.1)
    }

    /// Options for pipe creation (Linux).
    public struct Options: OptionSet, Sendable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Set the close-on-exec flag on the new file descriptors.
        public static let closeOnExec = Options(rawValue: O_CLOEXEC)

        /// Set the non-blocking flag on the new file descriptors.
        public static let nonBlock = Options(rawValue: O_NONBLOCK)

        /// Create a direct I/O pipe (Linux 3.4+).
        public static let direct = Options(rawValue: O_DIRECT)
    }
}

#endif
