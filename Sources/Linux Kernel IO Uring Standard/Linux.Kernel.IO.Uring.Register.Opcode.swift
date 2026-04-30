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

    extension ISO_9945.Kernel.IO.Uring.Register {
        /// Opcodes for registering resources with io_uring.
        ///
        /// Registration allows pre-registering buffers, files, and other
        /// resources with the kernel to avoid per-operation lookup overhead.
        /// This improves performance for frequently-used resources.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Register file descriptors for fast access
        /// var fds: [Int32] = [fd1.rawValue, fd2.rawValue]
        /// try fds.withUnsafeMutableBufferPointer { buffer in
        ///     try ISO_9945.Kernel.IO.Uring.register(
        ///         ring,
        ///         opcode: .files.register,
        ///         argument: buffer.baseAddress,
        ///         count: UInt32(buffer.count)
        ///     )
        /// }
        ///
        /// // Use registered fd in SQE (with .fixedFile flag)
        /// sqe.flags = [.fixedFile]
        /// sqe.fd = 0  // Index into registered files, not raw fd
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Uring``
        /// - ``Kernel/IO/Uring/Submission/Queue/Entry/Options``
        public struct Opcode: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {
        /// High-bit flag: use a registered ring descriptor for the register call.
        ///
        /// OR this with any register opcode to indicate the ring fd
        /// is an index into the registered ring fd array.
        ///
        /// - Linux: `IORING_REGISTER_USE_REGISTERED_RING`
        public static let useRegisteredRing = Self(rawValue: 1 << 31)
    }

    extension ISO_9945.Kernel.IO.Uring.Register {
        /// Flags for v2 resource registration arguments (`io_uring_rsrc_register`).
        public struct Resource {
            /// Register resources sparsely (leave unset slots as holes).
            ///
            /// - Linux: `IORING_RSRC_REGISTER_SPARSE`
            public static let sparse: UInt32 = 1
        }
    }

#endif
