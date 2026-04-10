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
    public import Kernel_Descriptor_Primitives
    public import Kernel_Error_Primitives
    public import Kernel_Memory_Primitives
    public import Kernel_File_Primitives

    extension Kernel.IO.Uring.Register {
        /// Probe registration opcodes.
        public struct Probe {
            /// Probes supported operations.
            ///
            /// Returns information about which opcodes are supported by
            /// the running kernel.
            ///
            /// - Linux: `IORING_REGISTER_PROBE`
            public static let register = Opcode(rawValue: 8)
        }
    }

    extension Kernel.IO.Uring.Register.Opcode {
        /// Access to probe registration opcodes.
        public static var probe: Kernel.IO.Uring.Register.Probe.Type { Kernel.IO.Uring.Register.Probe.self }
    }

#endif
