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

@_spi(Syscall) public import Error_Primitives
@_spi(Syscall) public import Path_Primitives

#if canImport(Glibc)
    internal import Glibc
    internal import CLinuxKernelShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Capability Probing

extension ISO_9945.Kernel.File.Clone.Capability {
    /// Probes whether the filesystem at the given path supports cloning.
    public static func probe(at path: borrowing Path.Borrowed) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) -> ISO_9945.Kernel.File.Clone.Capability {
        try unsafe path.withUnsafePointer { cString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
            var statfsBuf = statfs()
            let result = statfs(UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self), &statfsBuf)

            guard result == 0 else {
                throw ISO_9945.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .statfs)
            }

            // Known filesystems that support FICLONE
            // Btrfs: 0x9123683E
            // XFS: 0x58465342 (with reflink enabled)
            let fsMagic = statfsBuf.f_type
            if fsMagic == 0x9123683E || fsMagic == 0x58465342 {
                return .reflink
            }

            return .none
        }
    }
}

// MARK: - File Size

extension ISO_9945.Kernel.File.Clone.Metadata {
    /// Gets the size of a file.
    public static func size(at path: borrowing Path.Borrowed) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) -> Int {
        try unsafe path.withUnsafePointer { cString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
            var statBuf = Glibc.stat()
            let result = stat(UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self), &statBuf)

            guard result == 0 else {
                throw ISO_9945.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .stat)
            }

            return Int(statBuf.st_size)
        }
    }
}

// MARK: - FICLONE

private let _FICLONE: UInt = 0x4004_9409

extension ISO_9945.Kernel.File.Clone {
    /// Linux FICLONE operations.
    public enum Ficlone {
        /// Attempts to clone a file using ioctl(FICLONE) — raw fd SPI.
        ///
        /// Spec-literal: takes raw `Int32` fds. The L3-policy typed-descriptor
        /// convenience lives at swift-linux per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
        ///
        /// - Parameters:
        ///   - sourceFd: Source file raw fd (open for reading).
        ///   - destinationFd: Destination file raw fd (must be empty, open for writing).
        /// - Returns: `true` if cloned via FICLONE, `false` if the filesystem
        ///   does not support reflink (caller falls back to byte copy).
        @_spi(Syscall)
        public static func attempt(
            sourceFd: Int32,
            destinationFd: Int32
        ) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) -> Bool {
            let result = ioctl(destinationFd, _FICLONE, sourceFd)

            if result == 0 {
                return true
            }

            let err = errno
            if err == EOPNOTSUPP || err == ENOTSUP || err == EINVAL || err == EXDEV {
                return false
            }

            throw .platform(code: .posix(err), operation: .ficlone)
        }
    }

}

extension ISO_9945.Kernel.File.Clone.Ficlone {
    /// Attempts to clone a file using ioctl(FICLONE) — typed L2 form.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `attempt(sourceFd:destinationFd:)` SPI.
    public static func attempt(
        source: borrowing ISO_9945.Kernel.Descriptor,
        destination: borrowing ISO_9945.Kernel.Descriptor
    ) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) -> Bool {
        try attempt(sourceFd: source._rawValue, destinationFd: destination._rawValue)
    }
}

extension ISO_9945.Kernel.File.Clone {
    /// Linux copy_file_range operations.
    public enum CopyRange {
        /// Copies file data using copy_file_range() — raw fd SPI.
        ///
        /// Spec-literal: takes raw `Int32` fds. The L3-policy typed-descriptor
        /// convenience lives at swift-linux per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
        ///
        /// - Parameters:
        ///   - sourceFd: Source file raw fd (open for reading).
        ///   - destinationFd: Destination file raw fd (open for writing).
        ///   - length: Total number of bytes to copy.
        @_spi(Syscall)
        public static func copy(
            sourceFd: Int32,
            destinationFd: Int32,
            length: Int
        ) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) {
            var remaining = ISO_9945.Kernel.File.Size(length)
            var srcOffset = ISO_9945.Kernel.File.Offset(0)
            var dstOffset = ISO_9945.Kernel.File.Offset(0)

            while remaining > .zero {
                let copied: ISO_9945.Kernel.File.Size
                do {
                    copied = try ISO_9945.Kernel.Copy.Range.copy(
                        fromFd: sourceFd,
                        sourceOffset: &srcOffset,
                        toFd: destinationFd,
                        destOffset: &dstOffset,
                        length: remaining
                    )
                } catch {
                    throw .platform(code: .posix(errno), operation: .copyFileRange)
                }

                if copied == .zero {
                    break
                }

                remaining -= copied
            }
        }
    }
}

extension ISO_9945.Kernel.File.Clone.CopyRange {
    /// Copies file data using copy_file_range — typed L2 form.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `copy(sourceFd:destinationFd:length:)` SPI.
    public static func copy(
        source: borrowing ISO_9945.Kernel.Descriptor,
        destination: borrowing ISO_9945.Kernel.Descriptor,
        length: Int
    ) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) {
        try copy(sourceFd: source._rawValue, destinationFd: destination._rawValue, length: length)
    }
}

#endif
