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

    // Linux statfs magic-number residue, relocated from swift-iso-9945
    // (`Sources/ISO 9945 Core/Kernel.File.System.Kind.swift`) per
    // swift-iso/swift-iso-9945#64: the `ISO_9945.Kernel.File.System.Kind`
    // type itself stays at L2 (POSIX-shared statfs/GetVolumeInformation
    // wrapper); only the Linux-specific magic-number constants move to this
    // platform standard, matching the sanctioned platform-constant-extension
    // pattern.

    extension ISO_9945.Kernel.File.System.Kind {
        /// ext4 filesystem magic number.
        public static let ext4 = Self(rawValue: 0xEF53)

        /// Btrfs filesystem magic number.
        public static let btrfs = Self(rawValue: 0x9123_683E)

        /// XFS filesystem magic number.
        public static let xfs = Self(rawValue: 0x5846_5342)

        /// tmpfs filesystem magic number.
        public static let tmpfs = Self(rawValue: 0x0102_1994)

        /// proc filesystem magic number.
        public static let proc = Self(rawValue: 0x9FA0)

        /// sysfs filesystem magic number.
        public static let sysfs = Self(rawValue: 0x6265_6572)

        /// NFS filesystem magic number.
        public static let nfs = Self(rawValue: 0x6969)

        /// CIFS/SMB filesystem magic number.
        public static let cifs = Self(rawValue: 0xFF53_4D42)
    }

#endif
