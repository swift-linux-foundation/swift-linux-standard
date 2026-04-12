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

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring.Poll {
        /// Trigger mode for io_uring poll operations.
        ///
        /// Determines when the kernel delivers poll completions.
        ///
        /// - `.edge` (default): Fires once when the condition transitions
        ///   from not-ready to ready. The application must drain the fd
        ///   until `EAGAIN` and re-arm if needed.
        ///
        /// - `.level`: Fires whenever the condition is true. The kernel
        ///   re-delivers if the condition persists after the CQE is consumed.
        ///   Simpler to use but higher overhead under sustained readiness.
        public enum Trigger: Sendable, Hashable {
            /// Edge-triggered — fires on transition (default).
            case edge

            /// Level-triggered — fires while condition holds.
            case level
        }
    }

    extension Kernel.IO.Uring.Poll.Trigger {
        /// The io_uring poll flag bits for this trigger mode.
        @usableFromInline
        var pollBits: UInt32 {
            switch self {
            case .edge: 0
            case .level: UInt32(IORING_POLL_ADD_LEVEL)
            }
        }
    }

#endif
