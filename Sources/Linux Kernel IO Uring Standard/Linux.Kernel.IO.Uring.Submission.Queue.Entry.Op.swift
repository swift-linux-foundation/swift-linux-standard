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
    public import Kernel_IO_Primitives
    public import Kernel_Descriptor_Primitives
    public import Kernel_Error_Primitives
    public import Kernel_Memory_Primitives
    public import Kernel_File_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.Submission.Queue.Entry {
        /// Accessor for operation-specific properties.
        public var op: Op {
            get { Op(entry: self) }
            set { cValue.rw_flags = UInt32(bitPattern: newValue.flags) }
        }

        /// Operation-specific properties for submission entry.
        public struct Op: Sendable {
            /// Operation-specific flags.
            ///
            /// Note: Uses Int32 to match Linux kernel's `__kernel_rwf_t` type.
            public var flags: Int32

            init(entry: borrowing Kernel.IO.Uring.Submission.Queue.Entry) {
                self.flags = Int32(bitPattern: entry.cValue.rw_flags)
            }

            /// Creates an Op with the given flags.
            public init(flags: Int32) {
                self.flags = flags
            }
        }
    }

#endif
