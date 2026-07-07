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
    extension ISO_9945.Kernel.IO.Uring {
        /// Poll operation opcodes.
        public struct Poll {
            /// Poll for events on fd.
            public static let add = Opcode(rawValue: 6)

            /// Remove existing poll request.
            public static let remove = Opcode(rawValue: 7)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to poll operation opcodes.
        public static var poll: ISO_9945.Kernel.IO.Uring.Poll.Type { ISO_9945.Kernel.IO.Uring.Poll.self }
    }

#endif
