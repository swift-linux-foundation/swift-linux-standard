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
@_spi(Syscall) public import Random_Primitives
public import ISO_9945_Kernel_System

#if canImport(Glibc)
    internal import Glibc
    internal import CLinuxKernelShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux getrandom(2) syscall

extension Linux.Kernel.Random {
    /// Fills a mutable span with cryptographically secure random bytes using
    /// `getrandom(2)`.
    ///
    /// Uses the kernel's CSPRNG via `getrandom(2)`. Handles partial reads
    /// and EINTR automatically by retrying until the buffer is full.
    ///
    /// - Parameter span: The mutable span to fill with random bytes.
    /// - Throws: `Random.Error` if getrandom fails.
    public static func getrandom(_ span: inout MutableSpan<UInt8>) throws(Random.Error) {
        try unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Random.Error) in
            try unsafe getrandom(buffer)
        }
    }

    /// Fills a buffer with cryptographically secure random bytes using
    /// `getrandom(2)`.
    ///
    /// Uses the kernel's CSPRNG via `getrandom(2)`. Handles partial reads
    /// and EINTR automatically by retrying until the buffer is full.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.
    /// - Throws: `Random.Error` if getrandom fails.
    @unsafe
    public static func getrandom(_ buffer: UnsafeMutableRawBufferPointer) throws(Random.Error) {
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
                if errno == EINTR {
                    continue  // Retry on interrupt
                }
                if errno == EAGAIN {
                    throw .entropyNotReady
                }
                throw .systemError(errno)
            }

            // result == 0 shouldn't happen, but treat as error
            throw .systemError(0)
        }
    }

    /// Fills a typed buffer with cryptographically secure random bytes using
    /// `getrandom(2)`.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.
    /// - Throws: `Random.Error` if getrandom fails.
    @unsafe
    public static func getrandom(_ buffer: UnsafeMutableBufferPointer<UInt8>) throws(Random.Error) {
        try unsafe getrandom(UnsafeMutableRawBufferPointer(buffer))
    }
}

#endif
