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

#if os(Linux) || os(Android) || os(OpenBSD)

public import Kernel_Thread_Primitives
internal import CLinuxKernelShim

#if canImport(Glibc)
internal import Glibc
#elseif canImport(Musl)
internal import Musl
#elseif canImport(Bionic)
internal import Bionic
#endif

// MARK: - Linux.Kernel.Thread.Affinity Namespace

extension Linux.Kernel.Thread {
    /// Thread affinity operations on Linux-family kernels.
    ///
    /// Wraps `sched_setaffinity(2)` at L2 so higher layers do not call the
    /// raw syscall directly. Consumers at L3 (`swift-linux`'s
    /// `Linux.Thread.Affinity`) delegate here per [PLAT-ARCH-008c].
    public enum Affinity {}
}

// MARK: - Set Mask

extension Linux.Kernel.Thread.Affinity {
    /// Sets the CPU affinity mask for a thread via `sched_setaffinity(2)`.
    ///
    /// - Parameters:
    ///   - tid: Thread ID; `0` denotes the calling thread.
    ///   - cores: Set of CPU core IDs to include in the mask.
    /// - Throws: `Kernel.Thread.Affinity.Error.platform` with the POSIX errno
    ///   if the syscall fails.
    public static func setMask(
        tid: Int32 = 0,
        cores: Set<Int>
    ) throws(Kernel.Thread.Affinity.Error) {
        var mask = cpu_set_t()

        // Zero the mask
        unsafe withUnsafeMutablePointer(to: &mask) { ptr in
            let rawPtr = unsafe UnsafeMutableRawPointer(ptr)
            unsafe rawPtr.initializeMemory(as: UInt8.self, repeating: 0, count: MemoryLayout<cpu_set_t>.size)
        }

        // Set bits for each CPU (open-coded CPU_SET)
        for cpu in cores {
            unsafe withUnsafeMutablePointer(to: &mask) { maskPtr in
                let cpusPerLong = MemoryLayout<UInt>.size * 8
                let index = cpu / cpusPerLong
                let offset = cpu % cpusPerLong
                unsafe maskPtr.withMemoryRebound(
                    to: UInt.self,
                    capacity: MemoryLayout<cpu_set_t>.size / MemoryLayout<UInt>.size
                ) { longs in
                    unsafe longs[index] |= UInt(1) << offset
                }
            }
        }

        let result = unsafe withUnsafePointer(to: &mask) { maskPtr -> Int32 in
            unsafe swift_sched_setaffinity(
                tid,
                MemoryLayout<cpu_set_t>.size,
                UnsafeRawPointer(maskPtr)
            )
        }

        guard result == 0 else {
            throw .platform(.posix(errno))
        }
    }
}

#endif
