// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

    @_spi(Syscall) public import Kernel_Descriptor_Primitives
    @_spi(Syscall) public import Kernel_Error_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    internal import CLinuxKernelShim

    extension Kernel.Descriptor.Duplicate {
        /// Duplicates a file descriptor into an existing descriptor slot with
        /// flags (Linux) — raw fd SPI.
        ///
        /// Spec-literal: takes raw `Int32` source/destination fds. The L3-policy
        /// typed-descriptor convenience (with `inout Kernel.Descriptor`
        /// semantic-marker) lives at swift-linux per [PLAT-ARCH-005] /
        /// [PLAT-ARCH-008e]. Per Path X Phase 1 sub-cycle 1.7 Wave D Option A:
        /// dup3's destFd is a pure input from the kernel's perspective (the
        /// kernel atomically rebinds the resource at the slot; the slot number
        /// is unchanged on return), so L2 takes pure `Int32` inputs — no inout
        /// at L2 is needed and would be unrepresentable anyway because L1
        /// `Kernel.Descriptor._rawValue` is an SPI getter, not inout-projectable.
        ///
        /// Uses `dup3(2)` to duplicate a file descriptor while atomically
        /// setting flags on the new descriptor. The kernel resource previously
        /// held at the destination slot is closed atomically and the slot is
        /// repointed to a duplicate of source's resource.
        ///
        /// - Parameters:
        ///   - sourceFd: The raw fd to duplicate.
        ///   - destinationFd: The raw fd of the target slot.
        ///   - flags: Flags to apply (currently only O_CLOEXEC).
        /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure. On throw,
        ///   the destination slot is unchanged and still refers to its original
        ///   resource.
        @_spi(Syscall)
        public static func duplicate(
            sourceFd: Int32,
            destinationFd: Int32,
            flags: Options
        ) throws(Error) {
            let result = swift_dup3(sourceFd, destinationFd, flags.rawValue)

            guard result >= 0 else {
                let e = errno
                switch e {
                case EBADF:
                    throw .handle(.invalid)
                case EMFILE:
                    throw .tooManyOpen
                default:
                    throw .platform(Kernel.Error(code: .posix(e)))
                }
            }
        }

        /// Duplicates a file descriptor — typed L2 form.
        ///
        /// Phase 1.5 typed L2 form. Delegates to the raw
        /// `duplicate(sourceFd:destinationFd:flags:)` SPI.
        public static func duplicate(
            source: borrowing Kernel.Descriptor,
            destination: borrowing Kernel.Descriptor,
            flags: Options
        ) throws(Error) {
            try duplicate(
                sourceFd: source._rawValue,
                destinationFd: destination._rawValue,
                flags: flags
            )
        }
    }

#endif
