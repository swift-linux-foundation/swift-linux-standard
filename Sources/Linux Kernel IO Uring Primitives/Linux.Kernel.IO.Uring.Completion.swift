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

    extension Kernel.IO.Uring {
        /// Namespace for completion queue types.
        ///
        /// Contains types for the completion queue (CQ) side of io_uring,
        /// including queue entries, entry flags, and ring buffer offsets.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring/Completion/Queue``
        /// - ``Kernel/IO/Uring/Completion/Queue/Entry``
        /// - ``Kernel/IO/Uring/Submission``
        public enum Completion {}
    }

    extension Kernel.IO.Uring.Completion {
        /// Number of completion queue entries.
        ///
        /// Used for specifying how many completions to wait for in
        /// ``Kernel/IO/Uring/enter(_:toSubmit:minComplete:flags:)``.
        public typealias Count = Tagged<Kernel.IO.Uring.Completion, Cardinal>
    }

#endif
