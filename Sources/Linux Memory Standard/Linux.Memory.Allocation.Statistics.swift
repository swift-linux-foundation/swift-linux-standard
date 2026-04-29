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

public import Linux_Standard_Core
#if os(Linux)
import CLinuxMemoryShim
#endif

extension Linux_Standard_Core.Memory.Allocation {
    /// Memory allocation statistics for Linux.
    ///
    /// Uses LD_PRELOAD-based malloc/free hooks to track allocations.
    public struct Statistics: Sendable, Equatable {
        /// Number of allocations.
        public let allocations: Int

        /// Number of deallocations.
        public let deallocations: Int

        /// Total bytes allocated.
        public let bytesAllocated: Int

        /// Initialize allocation statistics.
        ///
        /// - Parameters:
        ///   - allocations: Number of allocations.
        ///   - deallocations: Number of deallocations.
        ///   - bytesAllocated: Total bytes allocated.
        public init(allocations: Int = 0, deallocations: Int = 0, bytesAllocated: Int = 0) {
            self.allocations = allocations
            self.deallocations = deallocations
            self.bytesAllocated = bytesAllocated
        }
    }
}

extension Linux_Standard_Core.Memory.Allocation.Statistics {
    /// Capture current allocation statistics.
    ///
    /// Returns the current state of allocation tracking counters.
    /// Requires `startTracking()` to have been called first.
    ///
    /// - Returns: Current allocation statistics.
    public static func capture() -> Self {
        #if os(Linux)
        let stats = tracking_current()
        return Self(
            allocations: Int(stats.allocations),
            deallocations: Int(stats.deallocations),
            bytesAllocated: Int(stats.bytes_allocated)
        )
        #else
        return Self()
        #endif
    }

    /// Start tracking allocations.
    ///
    /// Enables the LD_PRELOAD malloc/free hooks.
    /// Must be called before measuring allocations.
    public static func startTracking() {
        #if os(Linux)
        tracking_start()
        #endif
    }

    /// Stop tracking allocations and return final statistics.
    ///
    /// - Returns: Final allocation statistics since `startTracking()`.
    public static func stopTracking() -> Self {
        #if os(Linux)
        let stats = tracking_stop()
        return Self(
            allocations: Int(stats.allocations),
            deallocations: Int(stats.deallocations),
            bytesAllocated: Int(stats.bytes_allocated)
        )
        #else
        return Self()
        #endif
    }

    /// Reset tracking statistics to zero.
    ///
    /// Keeps tracking enabled but resets counters.
    public static func resetTracking() {
        #if os(Linux)
        tracking_reset()
        #endif
    }
}
