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

    extension Kernel.IO.Uring.Params.Submission {
        /// Thread configuration for submission queue polling.
        public struct Thread: Sendable, Equatable {
            /// CPU affinity for the SQ poll thread (when using `.sqAff` flag).
            public var cpu: System.Processor.ID

            /// Idle timeout before the SQ poll thread sleeps.
            public var idle: Duration

            /// Creates thread configuration.
            ///
            /// - Parameters:
            ///   - cpu: Processor to pin the poll thread to.
            ///   - idle: How long the poll thread waits before sleeping.
            public init(
                cpu: System.Processor.ID = .zero,
                idle: Duration = .zero
            ) {
                self.cpu = cpu
                self.idle = idle
            }
        }
    }

    // MARK: - C Boundary

    extension Kernel.IO.Uring.Params.Submission.Thread {
        /// Creates from C struct fields.
        internal init(cCpu: UInt32, cIdle: UInt32) {
            self.cpu = System.Processor.ID(__unchecked: (), Ordinal(UInt(cCpu)))
            self.idle = .milliseconds(Int(cIdle))
        }

        /// CPU as UInt32 for C struct.
        internal var cCpu: UInt32 {
            UInt32(cpu.rawValue.rawValue)
        }

        /// Idle as UInt32 milliseconds for C struct.
        internal var cIdle: UInt32 {
            let (seconds, attoseconds) = idle.components
            let ms = seconds * 1000 + attoseconds / 1_000_000_000_000_000
            return UInt32(clamping: ms)
        }
    }

#endif
