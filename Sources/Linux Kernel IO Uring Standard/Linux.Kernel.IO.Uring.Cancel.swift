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
        /// Cancel operation opcodes.
        public struct Cancel {
            /// Cancel in-flight async operation.
            public static let async = Opcode(rawValue: 14)
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Opcode {
        /// Access to cancel operation opcodes.
        public static var cancel: ISO_9945.Kernel.IO.Uring.Cancel.Type { ISO_9945.Kernel.IO.Uring.Cancel.self }
    }

#endif
