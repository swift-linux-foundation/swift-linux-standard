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

    extension Kernel.IO {
        /// I/O scheduling priority.
        ///
        /// Wraps the Linux `ioprio` format used by `ioprio_set(2)` and shared
        /// across multiple kernel subsystems (block I/O scheduler, io_uring, CFQ/BFQ).
        ///
        /// The value encodes two fields:
        /// - Bits 13–15: Priority class (`IOPRIO_CLASS_*`)
        /// - Bits 0–12: Priority level within the class
        ///
        /// ## Usage
        ///
        /// ```swift
        /// sqe.priority = .default
        /// sqe.priority = Kernel.IO.Priority(rawValue: IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 4))
        /// ```
        public struct Priority: RawRepresentable, Sendable, Equatable, Hashable, Comparable {
            public let rawValue: UInt16

            /// Creates a priority from a raw value.
            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }
        }
    }

    // MARK: - Common Values

    extension Kernel.IO.Priority {
        /// Creates a priority from a UInt16 value.
        public init(_ value: UInt16) {
            self.rawValue = value
        }

        /// Default priority (no priority set).
        public static let `default` = Self(0)

        /// Normal priority (best-effort, middle level).
        public static let normal = Self(0)
    }

    // MARK: - Comparable

    extension Kernel.IO.Priority {
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    // MARK: - ExpressibleByIntegerLiteral

    extension Kernel.IO.Priority: ExpressibleByIntegerLiteral {
        public init(integerLiteral value: UInt16) {
            self.rawValue = value
        }
    }

    // MARK: - CustomStringConvertible

    extension Kernel.IO.Priority: CustomStringConvertible {
        public var description: Swift.String {
            "\(rawValue)"
        }
    }

#endif
