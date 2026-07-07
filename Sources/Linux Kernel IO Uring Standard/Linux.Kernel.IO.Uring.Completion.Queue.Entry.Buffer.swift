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

    public import ISO_9945_Core
    extension ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry {
        /// Accessor for buffer-related properties.
        public var buffer: Buffer { Buffer(entry: self) }

        /// Buffer-related properties for completion entry.
        public struct Buffer: Sendable {
            let entry: ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry

            init(entry: ISO_9945.Kernel.IO.Uring.Completion.Queue.Entry) {
                self.entry = entry
            }

            /// The buffer index if a buffer was selected.
            ///
            /// Only valid when `.buffer` flag is set.
            public var index: ISO_9945.Kernel.IO.Uring.Buffer.Index? {
                guard entry.flags.contains(.buffer) else { return nil }
                return ISO_9945.Kernel.IO.Uring.Buffer.Index(
                    rawValue: UInt16(truncatingIfNeeded: entry.flags.rawValue >> 16)
                )
            }
        }
    }

#endif
