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
@_spi(Syscall) public import Kernel_Path_Primitives

#if canImport(Glibc)
    internal import Glibc
    internal import CLinuxKernelShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Capability Probing

extension Kernel.File.Clone.Capability {
    /// Probes whether the filesystem at the given path supports cloning.
    public static func probe(at path: borrowing Kernel.Path.Borrowed) throws(Kernel.File.Clone.Error.Syscall) -> Kernel.File.Clone.Capability {
        try unsafe path.withUnsafePointer { cString throws(Kernel.File.Clone.Error.Syscall) in
            var statfsBuf = statfs()
            let result = statfs(UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self), &statfsBuf)

            guard result == 0 else {
                throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .statfs)
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

extension Kernel.File.Clone.Metadata {
    /// Gets the size of a file.
    public static func size(at path: borrowing Kernel.Path.Borrowed) throws(Kernel.File.Clone.Error.Syscall) -> Int {
        try unsafe path.withUnsafePointer { cString throws(Kernel.File.Clone.Error.Syscall) in
            var statBuf = Glibc.stat()
            let result = stat(UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self), &statBuf)

            guard result == 0 else {
                throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .stat)
            }

            return Int(statBuf.st_size)
        }
    }
}

// MARK: - FICLONE

private let _FICLONE: UInt = 0x4004_9409

extension Kernel.File.Clone {
    /// Linux FICLONE operations.
    public enum Ficlone {
        /// Attempts to clone a file using ioctl(FICLONE).
        public static func attempt(
            source: borrowing Kernel.Descriptor,
            destination: borrowing Kernel.Descriptor
        ) throws(Kernel.File.Clone.Error.Syscall) -> Bool {
            let result = ioctl(destination._rawValue, _FICLONE, source._rawValue)

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

    /// Linux copy_file_range operations.
    public enum CopyRange {
        /// Copies file data using copy_file_range().
        public static func copy(
            source: borrowing Kernel.Descriptor,
            destination: borrowing Kernel.Descriptor,
            length: Int
        ) throws(Kernel.File.Clone.Error.Syscall) {
            var remaining = Kernel.File.Size(length)
            var srcOffset = Kernel.File.Offset(0)
            var dstOffset = Kernel.File.Offset(0)

            while remaining > .zero {
                let copied: Kernel.File.Size
                do {
                    copied = try Kernel.Copy.Range.copy(
                        from: source,
                        sourceOffset: &srcOffset,
                        to: destination,
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

#endif
