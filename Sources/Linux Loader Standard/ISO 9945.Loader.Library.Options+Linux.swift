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
    public import ISO_9945_Loader
    public import Loader_Primitives

    // RTLD_NOLOAD / RTLD_NODELETE residue, relocated from swift-iso-9945
    // (`Sources/ISO 9945 Loader/ISO 9945.Loader.Library.Options.swift`) per
    // swift-iso/swift-iso-9945#64. Neither flag is POSIX; both are glibc
    // extensions (available since glibc 2.2), but glibc's headers only
    // expose them behind a `_GNU_SOURCE` feature-test macro that this
    // package does not carry — so the raw uapi values are declared locally,
    // matching the `_FICLONE` local-constants precedent
    // (`Linux.Kernel.File.Clone.swift`).

    /// `RTLD_NOLOAD` — from glibc/musl `<dlfcn.h>` (`_GNU_SOURCE`-gated).
    private let _RTLD_NOLOAD: Int32 = 0x0000_4

    /// `RTLD_NODELETE` — from glibc/musl `<dlfcn.h>` (`_GNU_SOURCE`-gated).
    private let _RTLD_NODELETE: Int32 = 0x1000

    extension ISO_9945.Loader.Library.Options {
        /// Don't load, just check if loadable (RTLD_NOLOAD).
        ///
        /// Returns the handle if the library is already loaded,
        /// or fails without loading. Useful for probing.
        ///
        /// Non-POSIX extension. Available on glibc/musl since glibc 2.2.
        public static let noLoad = Self(rawValue: _RTLD_NOLOAD)

        /// Don't delete on close (RTLD_NODELETE).
        ///
        /// Keeps the library in memory even after `close`.
        /// The library's static destructors will not run.
        ///
        /// Non-POSIX extension. Available on glibc/musl since glibc 2.2.
        public static let noDelete = Self(rawValue: _RTLD_NODELETE)
    }

#endif
