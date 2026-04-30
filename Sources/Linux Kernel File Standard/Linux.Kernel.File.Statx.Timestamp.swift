#if os(Linux)


#if canImport(CLinuxKernelShim)
    internal import CLinuxKernelShim
#endif

extension ISO_9945.Kernel.File.Statx {
    /// Timestamp from a statx result.
    ///
    /// Wraps `struct statx_timestamp` — seconds since the epoch
    /// plus nanosecond precision.
    public struct Timestamp: @unchecked Sendable, Equatable {
        internal var cValue: statx_timestamp

        internal init(_ cValue: statx_timestamp) {
            self.cValue = cValue
        }

        /// Creates a timestamp.
        ///
        /// - Parameters:
        ///   - seconds: Seconds since the epoch.
        ///   - nanoseconds: Nanosecond component.
        public init(seconds: Int64 = 0, nanoseconds: UInt32 = 0) {
            self.cValue = statx_timestamp()
            self.cValue.tv_sec = seconds
            self.cValue.tv_nsec = nanoseconds
        }
    }
}

// MARK: - Accessors

extension ISO_9945.Kernel.File.Statx.Timestamp {
    /// Seconds since the epoch.
    public var seconds: Int64 {
        get { cValue.tv_sec }
    }

    /// Nanosecond component (0 ..< 1_000_000_000).
    public var nanoseconds: UInt32 {
        get { cValue.tv_nsec }
    }
}

// MARK: - Equatable

extension ISO_9945.Kernel.File.Statx.Timestamp {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.cValue.tv_sec == rhs.cValue.tv_sec && lhs.cValue.tv_nsec == rhs.cValue.tv_nsec
    }
}

#endif
