// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif
    @_spi(Syscall) public import Kernel_IO_Primitives

    // WORKAROUND: Pointer-backed view instead of Property.View — see Splice view.

    extension Kernel.IO.Uring.Submission.Queue.Entry.Prepare {
        /// Timeout operation field accessors.
        ///
        /// Provides typed access to the SQE fields used by timeout operations:
        /// completion count (`len`) and timeout configuration (`rw_flags` as
        /// clock source + timeout options).
        @usableFromInline
        struct Timeout {
            @usableFromInline
            let pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>

            @usableFromInline @unsafe
            init(pointer: UnsafeMutablePointer<Kernel.IO.Uring.Submission.Queue.Entry>) {
                self.pointer = unsafe pointer
            }

            /// Number of completions to wait for (0 = time only).
            @usableFromInline
            var count: UInt32 {
                get {
                    unsafe pointer.pointee.cValue.len
                }
                nonmutating set {
                    unsafe (pointer.pointee.cValue.len = newValue)
                }
            }

            /// Configure timeout flags from clock source and options.
            ///
            /// Combines clock bits and modifier flags (`.absolute`, `.multishot`)
            /// into the `rw_flags` field.
            @usableFromInline
            nonmutating func configure(
                clock: Kernel.IO.Uring.Clock,
                options: Kernel.IO.Uring.Timeout.Options = []
            ) {
                unsafe (pointer.pointee.cValue.rw_flags = clock.timeoutBits | options.rawValue)
            }
        }

        /// Access timeout operation fields.
        @inlinable
        var timeout: Timeout { unsafe Timeout(pointer: pointer) }
    }

#endif
