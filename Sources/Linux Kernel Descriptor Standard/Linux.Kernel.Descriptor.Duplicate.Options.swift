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

#if os(Linux)

    public import Kernel_Primitives_Core
    public import Kernel_Descriptor_Primitives
    public import Error_Primitives
    public import Kernel_File_Primitives
    public import Memory_Primitives
    public import Path_Primitives

    #if canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Kernel.Descriptor.Duplicate {
        /// Options for dup3(2).
        ///
        /// Controls the behavior of file descriptor duplication with flags.
        public struct Options: OptionSet, Sendable, Equatable, Hashable {
            public let rawValue: Int32

            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }

            /// Set the close-on-exec flag on the new file descriptor.
            public static let closeOnExec = Self(rawValue: O_CLOEXEC)
        }
    }

#endif
