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
public import System_Primitives
import Glibc

extension System.Memory {
    /// Total physical memory via `/proc/meminfo`.
    ///
    /// Returns the total installed RAM in bytes, parsed from the
    /// first line of `/proc/meminfo` (format: `MemTotal: <kB> kB`).
    public static var total: System.Memory.Capacity {
        guard let file = unsafe fopen("/proc/meminfo", "r") else {
            return System.Memory.Capacity(__unchecked: (), Cardinal(UInt(0)))
        }
        defer { unsafe fclose(file) }

        var buffer = [CChar](repeating: 0, count: 256)
        guard unsafe fgets(&buffer, Int32(buffer.count), file) != nil else {
            return System.Memory.Capacity(__unchecked: (), Cardinal(UInt(0)))
        }

        // First line: "MemTotal:       16384000 kB"
        let line = unsafe String(cString: buffer)
        var bytes: UInt = 0
        for char in line.unicodeScalars {
            if char >= "0" && char <= "9" {
                bytes = bytes &* 10 &+ UInt(char.value - 0x30)
            } else if bytes > 0 {
                break
            }
        }
        // /proc/meminfo reports in kB
        bytes = bytes &* 1024

        return System.Memory.Capacity(__unchecked: (), Cardinal(bytes))
    }
}
#else
public import System_Primitives

extension System.Memory {
    /// Stub for non-Linux platforms.
    public static var total: System.Memory.Capacity {
        System.Memory.Capacity(__unchecked: (), Cardinal(UInt(0)))
    }
}
#endif
