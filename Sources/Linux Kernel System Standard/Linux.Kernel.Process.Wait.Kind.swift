#if os(Linux)

public import Kernel_Process_Primitives

#if canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Process.Wait {
    /// Type of process identifier for waitid(2).
    public struct Kind: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension Kernel.Process.Wait.Kind {
    /// Wait for any child process.
    public static let all = Self(rawValue: Int32(bitPattern: UInt32(P_ALL.rawValue)))

    /// Wait for a specific process by PID.
    public static let pid = Self(rawValue: Int32(bitPattern: UInt32(P_PID.rawValue)))

    /// Wait for any child in a specific process group.
    public static let processGroup = Self(rawValue: Int32(bitPattern: UInt32(P_PGID.rawValue)))
}

#endif
