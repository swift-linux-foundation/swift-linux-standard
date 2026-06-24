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

public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Register {
        /// Personality registration opcodes.
        public struct Personality {
            /// Registers a personality (credentials) for operations.
            ///
            /// Allows running operations with different credentials.
            ///
            /// - Linux: `IORING_REGISTER_PERSONALITY`
            public static let register = Opcode(rawValue: 9)

            /// Unregisters a personality.
            ///
            /// - Linux: `IORING_UNREGISTER_PERSONALITY`
            public static let unregister = Opcode(rawValue: 10)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {
        /// Access to personality registration opcodes.
        public static var personality: ISO_9945.Kernel.IO.Uring.Register.Personality.Type { ISO_9945.Kernel.IO.Uring.Register.Personality.self }
    }

#endif
