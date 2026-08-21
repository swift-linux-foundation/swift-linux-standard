public import Linux_Standard_Core

#if os(Linux)
    import Linux_Memory_Shims
#endif

extension Linux.Memory.Allocation {

    public struct Statistics: Sendable, Equatable {

        public let allocations: Int

        public let deallocations: Int

        public let bytesAllocated: Int

        public init(allocations: Int = 0, deallocations: Int = 0, bytesAllocated: Int = 0) {
            self.allocations = allocations
            self.deallocations = deallocations
            self.bytesAllocated = bytesAllocated
        }
    }
}

extension Linux.Memory.Allocation.Statistics {

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

    public static func startTracking() {
        #if os(Linux)
            tracking_start()
        #endif
    }

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

    public static func resetTracking() {
        #if os(Linux)
            tracking_reset()
        #endif
    }
}
