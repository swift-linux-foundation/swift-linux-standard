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

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Kernel.IO.Uring.Socket {
        /// Flags for socket send/recv operations.
        ///
        /// Wraps MSG_* constants from `<sys/socket.h>`.
        /// Used by send, recv, sendmsg, recvmsg, and their zero-copy variants.
        public struct Message: Sendable {
            public struct Options: OptionSet, Sendable {
                public let rawValue: Int32

                @inlinable
                public init(rawValue: Int32) {
                    self.rawValue = rawValue
                }

                /// Don't block.
                public static let dontWait = Options(rawValue: Int32(MSG_DONTWAIT))

                /// Don't generate SIGPIPE.
                public static let noSignal = Options(rawValue: Int32(MSG_NOSIGNAL))

                /// Send out-of-band data.
                public static let outOfBand = Options(rawValue: Int32(MSG_OOB))

                /// Peek at incoming data without consuming.
                public static let peek = Options(rawValue: Int32(MSG_PEEK))

                /// Wait for full request or error.
                public static let waitAll = Options(rawValue: Int32(MSG_WAITALL))

                /// Send/receive data as end-of-record.
                public static let endOfRecord = Options(rawValue: Int32(MSG_EOR))

                /// Data completes connection.
                public static let confirm = Options(rawValue: Int32(MSG_CONFIRM))

                /// Hint that more data will follow.
                public static let more = Options(rawValue: Int32(MSG_MORE))

                /// Don't use a gateway to send out the packet.
                public static let dontRoute = Options(rawValue: Int32(MSG_DONTROUTE))

                /// Truncated message.
                public static let truncate = Options(rawValue: Int32(MSG_TRUNC))

                /// Control data was truncated.
                public static let controlTruncate = Options(rawValue: Int32(MSG_CTRUNC))
            }
        }
    }

#endif
