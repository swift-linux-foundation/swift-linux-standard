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

    public import Kernel_Event_Primitives
    public import Kernel_Descriptor_Primitives
    public import Kernel_Error_Primitives
    public import Kernel_Time_Primitives

    extension Kernel.Event.Poll {
        /// Namespace for epoll creation types.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Event/Poll/Create/Flags``
        public enum Create {}
    }

#endif
