// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)
    public import Kernel_IO_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(CLinuxKernelShim)
        internal import CLinuxKernelShim
    #endif

    extension Kernel.IO.Uring {
        /// Configuration and result parameters for io_uring setup.
        ///
        /// This struct serves dual purpose: you provide setup flags and thread
        /// configuration as input, and the kernel fills in ring sizes, offsets,
        /// and feature flags as output.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Create params with configuration
        /// var params = Kernel.IO.Uring.Params(
        ///     flags: [.sqPoll, .singleIssuer],
        ///     submission: .init(thread: .init(idle: .milliseconds(1000)))
        /// )
        ///
        /// // Setup fills in kernel-provided values
        /// let fd = try Kernel.IO.Uring.setup(entries: 256, params: &params)
        ///
        /// // Now params contains ring offsets for mmap
        /// print("SQ entries: \(params.sqEntries)")
        /// print("CQ entries: \(params.cqEntries)")
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring``
        /// - ``Kernel/IO/Uring/Setup/Options``
        public struct Params: Sendable, Equatable {
            /// Number of submission queue entries (filled by kernel).
            public private(set) var sqEntries: Kernel.IO.Uring.Submission.Count

            /// Number of completion queue entries (filled by kernel).
            public private(set) var cqEntries: Kernel.IO.Uring.Completion.Count

            /// Setup flags.
            public var flags: Setup.Options

            /// Submission queue thread configuration.
            public var submission: Submission

            /// Ring features supported by kernel (filled by kernel).
            public private(set) var features: Features

            /// Submission queue ring offset info (filled by kernel).
            public private(set) var sqOff: Kernel.IO.Uring.Submission.Queue.Offsets

            /// Completion queue ring offset info (filled by kernel).
            public private(set) var cqOff: Kernel.IO.Uring.Completion.Queue.Offsets

            /// Creates io_uring parameters for setup.
            ///
            /// - Parameters:
            ///   - flags: Setup flags to configure the ring.
            ///   - submission: Submission queue thread configuration.
            public init(
                flags: Setup.Options = [],
                submission: Submission = Submission()
            ) {
                self.sqEntries = Kernel.IO.Uring.Submission.Count.zero
                self.cqEntries = Kernel.IO.Uring.Completion.Count.zero
                self.flags = flags
                self.submission = submission
                self.features = Features(rawValue: 0)
                self.sqOff = Kernel.IO.Uring.Submission.Queue.Offsets()
                self.cqOff = Kernel.IO.Uring.Completion.Queue.Offsets()
            }

            /// Creates params from the C struct (after setup).
            internal init(_ cParams: io_uring_params) {
                self.sqEntries = Kernel.IO.Uring.Submission.Count(
                    __unchecked: (), Cardinal(UInt(cParams.sq_entries))
                )
                self.cqEntries = Kernel.IO.Uring.Completion.Count(
                    __unchecked: (), Cardinal(UInt(cParams.cq_entries))
                )
                self.flags = Setup.Options(rawValue: cParams.flags)
                self.submission = Submission(
                    thread: Submission.Thread(
                        cCpu: cParams.sq_thread_cpu,
                        cIdle: cParams.sq_thread_idle
                    )
                )
                self.features = Features(rawValue: cParams.features)
                self.sqOff = Kernel.IO.Uring.Submission.Queue.Offsets(cParams.sq_off)
                self.cqOff = Kernel.IO.Uring.Completion.Queue.Offsets(cParams.cq_off)
            }

        }
    }

    extension Kernel.IO.Uring.Params {
        /// Converts to the C io_uring_params struct.
        internal var cValue: io_uring_params {
            var params = io_uring_params()
            params.flags = flags.rawValue
            params.sq_thread_cpu = submission.thread.cCpu
            params.sq_thread_idle = submission.thread.cIdle
            return params
        }
    }

#endif
