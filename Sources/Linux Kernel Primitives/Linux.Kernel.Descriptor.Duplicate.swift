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

#if canImport(Glibc) || canImport(Musl)

    @_spi(Syscall) public import Kernel_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    internal import CLinuxKernelShim

    extension Kernel.Descriptor.Duplicate {
        /// Duplicates a file descriptor into an existing descriptor slot with
        /// flags (Linux).
        ///
        /// Uses `dup3(2)` to duplicate a file descriptor while atomically
        /// setting flags on the new descriptor. The kernel resource previously
        /// held at `newDescriptor`'s slot is closed atomically and the slot is
        /// repointed to a duplicate of `descriptor`'s resource.
        ///
        /// The `inout` parameter expresses that the wrapper is mutated in place:
        /// the slot number is unchanged, only the kernel resource it refers to
        /// has been replaced. No new owning `Kernel.Descriptor` is constructed.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor to duplicate.
        ///   - newDescriptor: The target slot, mutated in place.
        ///   - flags: Flags to apply (currently only O_CLOEXEC).
        /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure. On throw,
        ///   `newDescriptor` is unchanged and still refers to its original resource.
        public static func duplicate(
            _ descriptor: borrowing Kernel.Descriptor,
            to newDescriptor: inout Kernel.Descriptor,
            flags: Flags
        ) throws(Error) {
            let result = swift_dup3(descriptor._rawValue, newDescriptor._rawValue, flags.rawValue)

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
    }

#endif
