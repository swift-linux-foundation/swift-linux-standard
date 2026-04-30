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

    extension ISO_9945.Kernel.IO.Uring.Socket {
        /// Socket data transfer modifiers.
        ///
        /// Namespace for flags shared across send, receive, sendmsg,
        /// recvmsg, send_zc, and sendmsg_zc operations.
        public struct Transfer {}
    }

#endif
