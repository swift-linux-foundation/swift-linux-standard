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
    public import Kernel_IO_Primitives

    extension ISO_9945.Kernel.IO.Uring.Register {
        /// File registration opcodes.
        public struct Files {
            /// Registers file descriptors for fast access.
            ///
            /// Allows using fd indices instead of raw descriptors in SQEs
            /// (with `.fixedFile` flag), avoiding fd lookup overhead.
            ///
            /// - Linux: `IORING_REGISTER_FILES`
            public static let register = Opcode(rawValue: 2)

            /// Unregisters previously registered files.
            ///
            /// - Linux: `IORING_UNREGISTER_FILES`
            public static let unregister = Opcode(rawValue: 3)

            /// Updates registered files (add/remove without full re-register).
            ///
            /// - Linux: `IORING_REGISTER_FILES_UPDATE`
            public static let update = Opcode(rawValue: 6)

            /// Registers file descriptors (v2 API, kernel 5.13+).
            ///
            /// Supports sparse registration and resource tagging.
            ///
            /// - Linux: `IORING_REGISTER_FILES2`
            public static let register2 = Opcode(rawValue: 13)

            /// Updates registered files (v2 API, kernel 5.13+).
            ///
            /// - Linux: `IORING_REGISTER_FILES_UPDATE2`
            public static let update2 = Opcode(rawValue: 14)

            /// Access to file allocation sub-operations.
            public static var alloc: Alloc.Type { Alloc.self }

            /// Sentinel value to skip a slot during file update.
            ///
            /// - Linux: `IORING_REGISTER_FILES_SKIP`
            public static let skip: Int32 = -2

            /// Auto-allocate the next available file slot.
            ///
            /// - Linux: `IORING_FILE_INDEX_ALLOC`
            public static let indexAlloc: UInt32 = 0xFFFFFFFF
        }
    }

    extension ISO_9945.Kernel.IO.Uring.Register.Opcode {
        /// Access to file registration opcodes.
        public static var files: ISO_9945.Kernel.IO.Uring.Register.Files.Type { ISO_9945.Kernel.IO.Uring.Register.Files.self }
    }

#endif
