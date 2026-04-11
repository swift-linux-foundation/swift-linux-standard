#if os(Linux)

public import Kernel_Process_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Process.Wait {
    /// Options for waitid(2) specifying which state changes to report.
    public struct Options: OptionSet, Sendable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension Kernel.Process.Wait.Options {
    /// Wait for children that have exited.
    public static let exited = Self(rawValue: Int32(WEXITED))

    /// Wait for children that have been stopped by a signal.
    public static let stopped = Self(rawValue: Int32(WSTOPPED))

    /// Wait for stopped children that have continued.
    public static let continued = Self(rawValue: Int32(WCONTINUED))

    /// Do not remove the child from the waitable set.
    public static let noWait = Self(rawValue: Int32(WNOWAIT))
}

#endif
