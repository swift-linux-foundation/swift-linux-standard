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

    @_spi(Syscall) public import ISO_9945_Core
    public import ISO_9945_Kernel_File
    public import Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
        internal import CLinuxKernelShim
    #elseif canImport(Musl)
        internal import Musl
    #endif

    // MARK: - Linux FICLONE Implementation — raw fd SPI

    extension ISO_9945.Kernel.Copy.Clone {
        /// Clones a file using FICLONE ioctl — raw fd SPI.
        ///
        /// Spec-literal: takes raw `Int32` fds. The L3-policy typed-descriptor
        /// convenience (with `ISO_9945.Kernel.Descriptor.Validity` checks) lives at
        /// swift-linux per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
        ///
        /// Both files share the same data blocks until one is modified, making this
        /// extremely fast for large files on supported filesystems.
        ///
        /// ## Threading
        /// This call blocks until the clone operation completes. The clone is atomic
        /// from the filesystem's perspective.
        ///
        /// ## Filesystem Support
        /// Only works on filesystems with reflink capability:
        /// - Btrfs (full support)
        /// - XFS (with reflink enabled)
        ///
        /// ## Errors
        /// - ``Kernel/Copy/Error/unsupported``: Filesystem doesn't support FICLONE
        /// - ``Kernel/Copy/Error/crossDevice``: Source and destination on different filesystems
        /// - ``Kernel/Copy/Error/notEmpty``: Destination file is not empty
        ///
        /// - Parameters:
        ///   - sourceFd: Source file raw fd (open for reading).
        ///   - destinationFd: Destination file raw fd (must be empty, open for writing).
        ///
        /// - Throws: ``Kernel/Copy/Error`` on failure.
        internal static func perform(
            fromFd sourceFd: Int32,
            toFd destinationFd: Int32
        ) throws(ISO_9945.Kernel.Copy.Error) {
            let result = swift_ficlone(destinationFd, sourceFd)
            guard result == 0 else {
                throw ISO_9945.Kernel.Copy.Error(posixErrno: errno)
            }
        }

        /// Clones a file using FICLONE — typed L2 form.
        ///
        /// Phase 1.5 typed L2 form. Delegates to the raw `perform(fromFd:toFd:)` SPI.
        public static func perform(
            from source: borrowing ISO_9945.Kernel.Descriptor,
            to destination: borrowing ISO_9945.Kernel.Descriptor
        ) throws(ISO_9945.Kernel.Copy.Error) {
            try perform(fromFd: source._rawValue, toFd: destination._rawValue)
        }
    }

#endif
