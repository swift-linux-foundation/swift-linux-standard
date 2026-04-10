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

#if os(Linux) || os(Android) || os(OpenBSD)

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

// MARK: - Linux getrandom Implementation

extension Kernel.Random {
    /// Fills a mutable span with cryptographically secure random bytes.
    ///
    /// Uses the kernel's CSPRNG via getrandom(2). Handles partial reads
    /// and EINTR automatically by retrying until the buffer is full.
    ///
    /// - Parameter span: The mutable span to fill with random bytes.
    /// - Throws: `Error` if getrandom fails.

    public static func fill(_ span: inout MutableSpan<UInt8>) throws(Error) {
        try unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) in
            try unsafe fill(buffer)
        }
    }

    /// Fills a buffer with cryptographically secure random bytes.
    ///
    /// Uses the kernel's CSPRNG via getrandom(2). Handles partial reads
    /// and EINTR automatically by retrying until the buffer is full.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.
    /// - Throws: `Error` if getrandom fails.
    @unsafe
    public static func fill(_ buffer: UnsafeMutableRawBufferPointer) throws(Error) {
        guard let base = buffer.baseAddress else { return }
        let total = buffer.count
        guard total > 0 else { return }

        var filled = 0
        while filled < total {
            let result = unsafe swift_getrandom(
                unsafe base.advanced(by: filled),
                total - filled,
                0  // No flags - blocking mode
            )

            if result > 0 {
                filled += Int(result)
                continue
            }

            if result == -1 {
                let code = Kernel.Error.Code.posix(errno)
                if code.posix == EINTR {
                    continue  // Retry on interrupt
                }
                if code.posix == EAGAIN {
                    throw .wouldBlock
                }
                throw .platform(code)
            }

            // result == 0 shouldn't happen, but treat as error
            throw .platform(.posix(0))
        }
    }

    /// Fills a typed buffer with cryptographically secure random bytes.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.
    /// - Throws: `Error` if getrandom fails.

    @unsafe
    public static func fill(_ buffer: UnsafeMutableBufferPointer<UInt8>) throws(Error) {
        try unsafe fill(UnsafeMutableRawBufferPointer(buffer))
    }
}

#endif
