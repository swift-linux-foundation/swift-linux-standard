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

    extension ISO_9945.Kernel.Event.Poll {
        /// Namespace for epoll creation types.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Event/Poll/Create/Flags``
        public enum Create {}
    }

#endif
