// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-linux-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Linux)

    public import ISO_9945_Core
    public import Error_Primitives

    extension ISO_9945.Kernel.Timer.Descriptor {
        /// Errors from timer descriptor operations.
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// Failed to create timer descriptor (`timerfd_create(2)`).
            case create(Error_Primitives.Error.Code)
        }
    }

    extension ISO_9945.Kernel.Timer.Descriptor.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let code):
                return "timer descriptor creation failed (\(code))"
            }
        }
    }

    extension ISO_9945.Kernel.Timer.Descriptor.Error {
        /// The error code associated with this error.
        public var code: Error_Primitives.Error.Code {
            switch self {
            case .create(let code): return code
            }
        }
    }

#endif
