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
    public import Error_Primitives

    extension ISO_9945.Kernel.Event.Descriptor {
        /// Errors from event descriptor operations.
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// Failed to create event descriptor.
            case create(Error_Primitives.Error.Code)

            /// Failed to read from event descriptor.
            case read(Error_Primitives.Error.Code)

            /// Failed to write to event descriptor.
            case write(Error_Primitives.Error.Code)

            /// Operation would block (non-blocking mode).
            case wouldBlock
        }
    }

    extension ISO_9945.Kernel.Event.Descriptor.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let code):
                return "event descriptor creation failed (\(code))"
            case .read(let code):
                return "event descriptor read failed (\(code))"
            case .write(let code):
                return "event descriptor write failed (\(code))"
            case .wouldBlock:
                return "operation would block"
            }
        }
    }

    extension ISO_9945.Kernel.Event.Descriptor.Error {
        /// The error code associated with this error, if any.
        public var code: Error_Primitives.Error.Code? {
            switch self {
            case .create(let code): return code
            case .read(let code): return code
            case .write(let code): return code
            case .wouldBlock: return nil
            }
        }
    }

#endif

