// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-linux open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-linux project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Glibc) || canImport(Musl)

    public import Kernel_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Kernel.Descriptor.Duplicate {
        /// Flags for dup3(2).
        ///
        /// Controls the behavior of file descriptor duplication with flags.
        public struct Flags: OptionSet, Sendable, Equatable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }

            /// Set the close-on-exec flag on the new file descriptor.
            public static let closeOnExec = Flags(rawValue: O_CLOEXEC)
        }
    }

#endif
